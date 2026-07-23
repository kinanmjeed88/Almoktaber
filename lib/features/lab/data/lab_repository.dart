import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:isar/isar.dart';

import '../../../core/models/lab.dart';
import '../../../core/models/device.dart';
import '../../../core/models/maintenance_log.dart';
import '../../../core/models/photo_record.dart';
import '../../../core/providers/db_provider.dart';

final labRepositoryProvider = Provider<LabRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return LabRepository(isar);
});

final labsProvider = FutureProvider<List<Lab>>((ref) async {
  final repository = ref.watch(labRepositoryProvider);
  return repository.getAllLabs();
});

class LabRepository {
  final Isar isar;

  LabRepository(this.isar);

  Future<void> addLab(Lab lab) async {
    await isar.writeTxn(() async {
      await isar.labs.put(lab);
    });
  }

  Future<void> updateLab(Lab lab) async {
    await isar.writeTxn(() async {
      await isar.labs.put(lab);
    });
  }

  Future<void> deleteLab(int id) async {
    await isar.writeTxn(() async {
      final lab = await isar.labs.get(id);
      if (lab != null) {
        final devices = await isar.devices.filter().lab((q) => q.idEqualTo(id)).findAll();
        for (var device in devices) {
          final photos = await isar.photoRecords.filter().device((q) => q.idEqualTo(device.id)).findAll();
          for (var photo in photos) {
            if (File(photo.imagePath).existsSync()) {
              File(photo.imagePath).deleteSync();
            }
          }
          if (photos.isNotEmpty) {
            await isar.photoRecords.deleteAll(photos.map((e) => e.id).toList());
          }

          final logs = await isar.maintenanceLogs.filter().device((q) => q.idEqualTo(device.id)).findAll();
          if (logs.isNotEmpty) {
             await isar.maintenanceLogs.deleteAll(logs.map((e) => e.id).toList());
          }
        }

        if (devices.isNotEmpty) {
          await isar.devices.deleteAll(devices.map((e) => e.id).toList());
        }

        await isar.labs.delete(id);
      }
    });
  }

  Future<List<Lab>> getAllLabs() async {
    return await isar.labs.where().findAll();
  }

  Future<Lab?> getLabById(int id) async {
    return await isar.labs.get(id);
  }

  Future<void> clearAll() async {
      await isar.writeTxn(() async {
          await isar.labs.clear();
      });
  }

  Future<void> putAll(List<Lab> labs) async {
      await isar.writeTxn(() async {
          await isar.labs.putAll(labs);
      });
  }
}
