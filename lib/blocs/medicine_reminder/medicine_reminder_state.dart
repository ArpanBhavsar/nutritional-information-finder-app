part of 'medicine_reminder_bloc.dart';

abstract class MedicineReminderState extends Equatable {
  const MedicineReminderState();

  @override
  List<Object> get props => [];
}

class ReminderInitial extends MedicineReminderState {}

class ReminderLoading extends MedicineReminderState {}

class ReminderLoaded extends MedicineReminderState {
  final List<MedicineReminder> reminders;
  const ReminderLoaded(this.reminders);

  @override
  List<Object> get props => [reminders];
}

class ReminderError extends MedicineReminderState {
  final String message;
  const ReminderError(this.message);

  @override
  List<Object> get props => [message];
}
