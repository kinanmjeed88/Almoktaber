import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:isar/isar.dart';

import '../../../core/models/maintenance_log.dart';
import '../../../core/models/photo_record.dart';
import '../../../core/models/device.dart';
import '../../../core/providers/db_provider.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return MaintenanceRepository(isar);
});

final maintenanceLogsByDeviceProvider = FutureProvider.family<List<MaintenanceLog>, int>((ref, deviceId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getLogsByDeviceId(deviceId);
});

class MaintenanceRepository {
  final Isar isar;

  MaintenanceRepository(this.isar);

  Future<void> addLog(MaintenanceLog log, Device device) async {
    await isar.writeTxn(() async {
      await isar.maintenanceLogs.put(log);
      log.device.value = device;
      await log.device.save();
    });
  }

  Future<void> updateLog(MaintenanceLog log) async {
    await isar.writeTxn(() async {
      await isar.maintenanceLogs.put(log);
      await log.device.save();
    });
  }

  Future<void> deleteLog(int id) async {
    await isar.writeTxn(() async {
      final photos = await isar.photoRecords.filter().maintenanceLog((q) => q.idEqualTo(id)).findAll();
      for (var photo in photos) {
        if (File(photo.imagePath).existsSync()) {
          File(photo.imagePath).deleteSync();
        }
      }
      if (photos.isNotEmpty) {
        await isar.photoRecords.deleteAll(photos.map((e) => e.id).toList());
      }
      await isar.maintenanceLogs.delete(id);
    });
  }

  Future<List<MaintenanceLog>> getLogsByDeviceId(int deviceId) async {
    return await isar.maintenanceLogs.filter().device((q) => q.idEqualTo(deviceId)).sortByMaintenanceDateDesc().findAll();
  }
}
