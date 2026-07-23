import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/device.dart';
import '../models/lab.dart';
import '../models/maintenance_log.dart';
import '../models/photo_record.dart';

class BackupService {
  final Isar isar;

  BackupService(this.isar);

  Future<void> exportData() async {
    final labs = await isar.labs.where().findAll();
    final devices = await isar.devices.where().findAll();
    final logs = await isar.maintenanceLogs.where().findAll();
    final photos = await isar.photoRecords.where().findAll();

    final data = {
      'labs': labs.map((l) => {
        'id': l.id,
        'name': l.name,
        'location': l.location,
      }).toList(),
      'devices': devices.map((d) => {
        'id': d.id,
        'name': d.name,
        'type': d.type,
        'quantity': d.quantity,
        'phoneNumber': d.phoneNumber,
        'materialCost': d.materialCost,
        'testsCount': d.testsCount,
        'creationDate': d.creationDate.toIso8601String(),
        'nextMaintenanceDate': d.nextMaintenanceDate.toIso8601String(),
        'notes': d.notes,
        'labId': d.lab.value?.id,
      }).toList(),
      'logs': logs.map((log) => {
        'id': log.id,
        'fault': log.fault,
        'solution': log.solution,
        'maintenanceDate': log.maintenanceDate.toIso8601String(),
        'deviceId': log.device.value?.id,
      }).toList(),
      'photos': photos.map((p) => {
        'id': p.id,
        'imagePath': p.imagePath,
        'note': p.note,
        'deviceId': p.device.value?.id,
        'logId': p.maintenanceLog.value?.id,
      }).toList(),
    };

    final jsonString = jsonEncode(data);
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية من بيانات المختبر');
  }

  Future<void> importData(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await isar.writeTxn(() async {
      await isar.clear();

      final labsData = data['labs'] as List<dynamic>? ?? [];
      final labMap = <int, Lab>{};
      for (var l in labsData) {
        final lab = Lab(name: l['name'], location: l['location'])..id = l['id'];
        labMap[lab.id] = lab;
        await isar.labs.put(lab);
      }

      final devicesData = data['devices'] as List<dynamic>? ?? [];
      final deviceMap = <int, Device>{};
      for (var d in devicesData) {
        final device = Device(
          name: d['name'],
          type: d['type'],
          quantity: d['quantity'],
          phoneNumber: d['phoneNumber'],
          materialCost: d['materialCost'],
          testsCount: d['testsCount'],
          creationDate: DateTime.parse(d['creationDate']),
          nextMaintenanceDate: DateTime.parse(d['nextMaintenanceDate']),
          notes: d['notes'],
        )..id = d['id'];
        if (d['labId'] != null && labMap.containsKey(d['labId'])) {
           device.lab.value = labMap[d['labId']];
        }
        deviceMap[device.id] = device;
        await isar.devices.put(device);
        if (device.lab.value != null) await device.lab.save();
      }

      final logsData = data['logs'] as List<dynamic>? ?? [];
      final logMap = <int, MaintenanceLog>{};
      for (var l in logsData) {
        final log = MaintenanceLog(
          fault: l['fault'],
          solution: l['solution'],
          maintenanceDate: DateTime.parse(l['maintenanceDate']),
        )..id = l['id'];
        if (l['deviceId'] != null && deviceMap.containsKey(l['deviceId'])) {
          log.device.value = deviceMap[l['deviceId']];
        }
        logMap[log.id] = log;
        await isar.maintenanceLogs.put(log);
        if (log.device.value != null) await log.device.save();
      }

      final photosData = data['photos'] as List<dynamic>? ?? [];
      for (var p in photosData) {
        final photo = PhotoRecord(
          imagePath: p['imagePath'],
          note: p['note'],
        )..id = p['id'];
        if (p['deviceId'] != null && deviceMap.containsKey(p['deviceId'])) {
           photo.device.value = deviceMap[p['deviceId']];
        }
        if (p['logId'] != null && logMap.containsKey(p['logId'])) {
           photo.maintenanceLog.value = logMap[p['logId']];
        }
        await isar.photoRecords.put(photo);
        if (photo.device.value != null) await photo.device.save();
        if (photo.maintenanceLog.value != null) await photo.maintenanceLog.save();
      }
    });
  }
}
