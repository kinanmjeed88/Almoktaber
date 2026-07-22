import 'package:isar/isar.dart';
import 'device.dart';
import 'maintenance_log.dart';

part 'photo_record.g.dart';

@collection
class PhotoRecord {
  Id id = Isar.autoIncrement;

  late String imagePath;
  String? note;

  final device = IsarLink<Device>();
  final maintenanceLog = IsarLink<MaintenanceLog>();

  PhotoRecord({
    required this.imagePath,
    this.note,
  });

  PhotoRecord.empty();
}
