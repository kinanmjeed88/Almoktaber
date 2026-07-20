import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/lab.dart';
import '../../../core/providers/db_provider.dart';

final labRepositoryProvider = Provider<LabRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return LabRepository(isar);
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
      await isar.labs.delete(id);
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
