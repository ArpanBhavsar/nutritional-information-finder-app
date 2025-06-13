import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/database_service.dart';
import '../../models/medicine_reminder.dart';
import '../../services/notification_service.dart';

part 'medicine_reminder_event.dart';
part 'medicine_reminder_state.dart';

class MedicineReminderBloc extends Bloc<MedicineReminderEvent, MedicineReminderState> {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  MedicineReminderBloc({required DatabaseService databaseService, required NotificationService notificationService})
    : _databaseService = databaseService,
      _notificationService = notificationService,
      super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
  }

  Future<void> _onLoadReminders(LoadReminders event, Emitter<MedicineReminderState> emit) async {
    emit(ReminderLoading());
    try {
      final reminders = await _databaseService.getReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(AddReminder event, Emitter<MedicineReminderState> emit) async {
    try {
      // Insert into DB to get the auto-incremented ID
      final newId = await _databaseService.insertReminder(event.reminder);
      final newReminder = event.reminder.copyWith(id: newId);

      // Schedule notifications with the new ID
      await _notificationService.scheduleReminderNotification(newReminder);

      // Reload the list
      add(LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdateReminder(UpdateReminder event, Emitter<MedicineReminderState> emit) async {
    try {
      // First, cancel old notifications
      await _notificationService.cancelReminderNotification(event.reminder.id!);

      // Then, update the DB
      await _databaseService.updateReminder(event.reminder);

      // Finally, schedule new notifications
      await _notificationService.scheduleReminderNotification(event.reminder);

      add(LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(DeleteReminder event, Emitter<MedicineReminderState> emit) async {
    try {
      // Cancel notifications first
      await _notificationService.cancelReminderNotification(event.reminderId);

      // Then delete from DB
      await _databaseService.deleteReminder(event.reminderId);

      add(LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
}
