import 'package:isar/isar.dart';
import 'lab.dart';

part 'device.g.dart';

@collection
class Device {
  Id id = Isar.autoIncrement;

  late String name;
  late String type;
  late int quantity;
  late String phoneNumber;
  late double materialCost;
  late int testsCount;
  late DateTime creationDate;
  String? notes;

  late DateTime nextMaintenanceDate;

  final lab = IsarLink<Lab>();

  Device({
    required this.name,
    required this.type,
    required this.quantity,
    required this.phoneNumber,
    required this.materialCost,
    required this.testsCount,
    required this.creationDate,
    required this.nextMaintenanceDate,
    this.notes,
  });

  Device.empty();
}
