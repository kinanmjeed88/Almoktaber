import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/maintenance_log.dart';
import '../../../core/providers/db_provider.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return MaintenanceRepository(isar);
});

class MaintenanceRepository {
  final Isar isar;

  MaintenanceRepository(this.isar);

  Future<void> addLog(MaintenanceLog log) async {
    await isar.writeTxn(() async {
      await isar.maintenanceLogs.put(log);
    });
  }

  Future<void> updateLog(MaintenanceLog log) async {
    await isar.writeTxn(() async {
      await isar.maintenanceLogs.put(log);
    });
  }

  Future<void> deleteLog(int id) async {
    await isar.writeTxn(() async {
      await isar.maintenanceLogs.delete(id);
    });
  }

  Future<List<MaintenanceLog>> getAllLogs() async {
    return await isar.maintenanceLogs.where().findAll();
  }

  Future<List<MaintenanceLog>> getLogsByLabId(int labId) async {
    return await isar.maintenanceLogs.filter().labIdEqualTo(labId).findAll();
  }

  Future<void> clearAll() async {
      await isar.writeTxn(() async {
          await isar.maintenanceLogs.clear();
      });
  }

  Future<void> putAll(List<MaintenanceLog> logs) async {
      await isar.writeTxn(() async {
          await isar.maintenanceLogs.putAll(logs);
      });
  }
}
