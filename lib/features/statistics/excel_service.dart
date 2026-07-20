import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../lab/data/lab_repository.dart';
import '../maintenance/data/maintenance_repository.dart';

final excelServiceProvider = Provider<ExcelService>((ref) {
  final labRepo = ref.watch(labRepositoryProvider);
  final logRepo = ref.watch(maintenanceRepositoryProvider);
  return ExcelService(labRepo, logRepo);
});

class ExcelService {
  final LabRepository labRepo;
  final MaintenanceRepository logRepo;

  ExcelService(this.labRepo, this.logRepo);

  Future<void> exportToExcel(BuildContext context) async {
    try {
      var excel = Excel.createExcel();

      // Labs Sheet
      Sheet labSheet = excel['المختبرات'];
      excel.setDefaultSheet('المختبرات');
      labSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('الاسم'),
        TextCellValue('الموقع'),
        TextCellValue('السعة')
      ]);

      final labs = await labRepo.getAllLabs();
      for (var lab in labs) {
        labSheet.appendRow([
          TextCellValue(lab.id.toString()),
          TextCellValue(lab.name),
          TextCellValue(lab.location),
          TextCellValue(lab.capacity.toString()),
        ]);
      }

      // Logs Sheet
      Sheet logSheet = excel['سجلات الصيانة'];
      logSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('العنوان'),
        TextCellValue('الوصف'),
        TextCellValue('التاريخ'),
        TextCellValue('معرف المختبر')
      ]);

      final logs = await logRepo.getAllLogs();
      for (var log in logs) {
        logSheet.appendRow([
          TextCellValue(log.id.toString()),
          TextCellValue(log.title),
          TextCellValue(log.description),
          TextCellValue(log.date.toIso8601String()),
          TextCellValue(log.labId.toString()),
        ]);
      }

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/statistics.xlsx');
        await file.writeAsBytes(fileBytes);

        final xFile = XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        await Share.shareXFiles([xFile], text: 'إحصاءات النظام');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تصدير Excel: $e')),
        );
      }
    }
  }
}
