import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MedicineReminder extends Equatable {
  final int? id;
  final String medicineId;
  final String medicineName; // Denormalized for easy display
  final TimeOfDay time;
  final List<String> days; // e.g., ['Monday', 'Wednesday', 'Friday']

  const MedicineReminder({this.id, required this.medicineId, required this.medicineName, required this.time, required this.days});

  // For storing in SQLite, we convert TimeOfDay and List to basic types
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'time': '${time.hour}:${time.minute}', // Store time as "HH:mm" string
      'days': days.join(','), // Store days as comma-separated string
    };
  }

  // For creating an instance from a map from SQLite
  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return MedicineReminder(
      id: map['id'],
      medicineId: map['medicineId'],
      medicineName: map['medicineName'],
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      days: (map['days'] as String).split(','),
    );
  }

  // Helper to create a copy with some updated fields
  MedicineReminder copyWith({int? id, String? medicineId, String? medicineName, TimeOfDay? time, List<String>? days}) {
    return MedicineReminder(id: id ?? this.id, medicineId: medicineId ?? this.medicineId, medicineName: medicineName ?? this.medicineName, time: time ?? this.time, days: days ?? this.days);
  }

  @override
  List<Object?> get props => [id, medicineId, medicineName, time, days];
}
