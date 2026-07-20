import 'package:isar/isar.dart';

part 'maintenance_log.g.dart';

@collection
class MaintenanceLog {
  Id id = Isar.autoIncrement;

  late String title;

  late String description;

  late DateTime date;

  late int labId;

  String? imagePath;

  MaintenanceLog({
    required this.title,
    required this.description,
    required this.date,
    required this.labId,
    this.imagePath,
  });

  MaintenanceLog.empty();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'labId': labId,
      'imagePath': imagePath,
    };
  }

  factory MaintenanceLog.fromJson(Map<String, dynamic> json) {
    return MaintenanceLog(
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      labId: json['labId'] as int,
      imagePath: json['imagePath'] as String?,
    )..id = json['id'] as int;
  }
}
