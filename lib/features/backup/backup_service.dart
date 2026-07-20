import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/lab.dart';
import '../../core/models/maintenance_log.dart';
import '../lab/data/lab_repository.dart';
import '../maintenance/data/maintenance_repository.dart';
import '../lab/presentation/labs_screen.dart';
import '../maintenance/presentation/maintenance_screen.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final labRepo = ref.watch(labRepositoryProvider);
  final logRepo = ref.watch(maintenanceRepositoryProvider);
  return BackupService(labRepo, logRepo, ref);
});

class BackupService {
  final LabRepository labRepo;
  final MaintenanceRepository logRepo;
  final Ref ref;

  BackupService(this.labRepo, this.logRepo, this.ref);

  Future<void> exportData(BuildContext context) async {
    try {
      final labs = await labRepo.getAllLabs();
      final logs = await logRepo.getAllLogs();

      final data = {
        'labs': labs.map((e) => e.toJson()).toList(),
        'logs': logs.map((e) => e.toJson()).toList(),
      };

      final jsonStr = jsonEncode(data);

      final archive = Archive();
      final fileData = utf8.encode(jsonStr);
      final archiveFile = ArchiveFile('backup.json', fileData.length, fileData);
      archive.addFile(archiveFile);

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) throw Exception('Failed to encode zip file');

      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/backup_data.zip');
      await backupFile.writeAsBytes(zipData);

      final xFile = XFile(backupFile.path, mimeType: 'application/zip');
      await Share.shareXFiles(
        [xFile],
        text: 'نسخة احتياطية لنظام إدارة المختبرات',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تجهيز النسخة الاحتياطية للمشاركة')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء النسخ الاحتياطي: $e')),
        );
      }
    }
  }

  Future<void> importData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        String jsonStr = '';

        if (filePath.endsWith('.zip')) {
          final bytes = await file.readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);

          for (final file in archive) {
            if (file.isFile && file.name.endsWith('.json')) {
              final data = file.content as List<int>;
              jsonStr = utf8.decode(data);
              break;
            }
          }
          if (jsonStr.isEmpty) throw Exception('الملف المضغوط لا يحتوي على بيانات صحيحة');
        } else if (filePath.endsWith('.json')) {
          jsonStr = await file.readAsString();
        } else {
           throw Exception('صيغة الملف غير مدعومة');
        }

        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final List<dynamic> labsData = data['labs'] ?? [];
        final List<dynamic> logsData = data['logs'] ?? [];

        final labs = labsData.map((e) => Lab.fromJson(e as Map<String, dynamic>)).toList();
        final logs = logsData.map((e) => MaintenanceLog.fromJson(e as Map<String, dynamic>)).toList();

        await labRepo.clearAll();
        await logRepo.clearAll();

        if (labs.isNotEmpty) await labRepo.putAll(labs);
        if (logs.isNotEmpty) await logRepo.putAll(logs);

        // UI blocking loading state implicitly handled by UI components returning FutureProvider when ref is invalidated
        ref.invalidate(labsProvider);
        ref.invalidate(maintenanceLogsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت استعادة النسخة الاحتياطية بنجاح')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل استعادة النسخة الاحتياطية: $e')),
        );
      }
    }
  }
}
