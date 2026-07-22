import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/device.dart';
import '../../../core/models/lab.dart';
import '../../../core/providers/db_provider.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return DeviceRepository(isar);
});

final devicesByLabProvider = FutureProvider.family<List<Device>, int>((ref, labId) async {
  final repository = ref.watch(deviceRepositoryProvider);
  return repository.getDevicesByLabId(labId);
});

class DeviceRepository {
  final Isar isar;

  DeviceRepository(this.isar);

  Future<void> addDevice(Device device, Lab lab) async {
    await isar.writeTxn(() async {
      await isar.devices.put(device);
      device.lab.value = lab;
      await device.lab.save();
    });
  }

  Future<void> updateDevice(Device device) async {
    await isar.writeTxn(() async {
      await isar.devices.put(device);
      await device.lab.save();
    });
  }

  Future<void> deleteDevice(int id) async {
    await isar.writeTxn(() async {
      final device = await isar.devices.get(id);
      if (device != null) {
        // Also delete related photos and maintenance logs if needed
        await isar.devices.delete(id);
      }
    });
  }

  Future<List<Device>> getDevicesByLabId(int labId) async {
    final lab = await isar.labs.get(labId);
    if (lab == null) return [];

    return await isar.devices.filter().lab((q) => q.idEqualTo(labId)).findAll();
  }

  Future<Device?> getDeviceById(int id) async {
    return await isar.devices.get(id);
  }
}
