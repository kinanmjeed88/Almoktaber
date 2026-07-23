import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/lab.dart';
import '../models/device.dart';
import '../models/maintenance_log.dart';
import '../models/photo_record.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main.dart');
});

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [LabSchema, DeviceSchema, MaintenanceLogSchema, PhotoRecordSchema],
    directory: dir.path,
  );
}

// Global provider to force refresh after restore
final refreshProvider = StateProvider<int>((ref) => 0);
