part of 'medicine_reminder_bloc.dart';

abstract class MedicineReminderEvent extends Equatable {
  const MedicineReminderEvent();

  @override
  List<Object> get props => [];
}

class LoadReminders extends MedicineReminderEvent {}

class AddReminder extends MedicineReminderEvent {
  final MedicineReminder reminder;
  const AddReminder(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class UpdateReminder extends MedicineReminderEvent {
  final MedicineReminder reminder;
  const UpdateReminder(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class DeleteReminder extends MedicineReminderEvent {
  final int reminderId;
  const DeleteReminder(this.reminderId);

  @override
  List<Object> get props => [reminderId];
}
