import 'package:isar/isar.dart';
import 'device.dart';

part 'maintenance_log.g.dart';

@collection
class MaintenanceLog {
  Id id = Isar.autoIncrement;

  late String fault;
  late String solution;
  late DateTime maintenanceDate;

  final device = IsarLink<Device>();

  MaintenanceLog({
    required this.fault,
    required this.solution,
    required this.maintenanceDate,
  });

  MaintenanceLog.empty();
}
