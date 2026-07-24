import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:isar/isar.dart';

import '../../../core/models/photo_record.dart';
import '../../../core/models/device.dart';
import '../../../core/models/maintenance_log.dart';
import '../../../core/providers/db_provider.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return PhotoRepository(isar);
});

final photosByDeviceProvider = FutureProvider.family<List<PhotoRecord>, int>((ref, deviceId) async {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.getPhotosByDeviceId(deviceId);
});

class PhotoRepository {
  final Isar isar;

  PhotoRepository(this.isar);

  Future<void> addPhotoToDevice(PhotoRecord photo, Device device) async {
    await isar.writeTxn(() async {
      await isar.photoRecords.put(photo);
      photo.device.value = device;
      await photo.device.save();
    });
  }

  Future<void> addPhotoToLog(PhotoRecord photo, MaintenanceLog log) async {
    await isar.writeTxn(() async {
      await isar.photoRecords.put(photo);
      photo.maintenanceLog.value = log;
      await photo.maintenanceLog.save();
    });
  }

  Future<void> updatePhoto(PhotoRecord photo) async {
    await isar.writeTxn(() async {
      await isar.photoRecords.put(photo);
    });
  }

  Future<void> deletePhoto(int id) async {
    await isar.writeTxn(() async {
      final photo = await isar.photoRecords.get(id);
      if (photo != null) {
        if (File(photo.imagePath).existsSync()) {
          File(photo.imagePath).deleteSync();
        }
        await isar.photoRecords.delete(id);
      }
    });
  }

  Future<List<PhotoRecord>> getPhotosByDeviceId(int deviceId) async {
    return await isar.photoRecords.filter().device((q) => q.idEqualTo(deviceId)).findAll();
  }

  Future<List<PhotoRecord>> getPhotosByLogId(int logId) async {
    return await isar.photoRecords.filter().maintenanceLog((q) => q.idEqualTo(logId)).findAll();
  }
}
