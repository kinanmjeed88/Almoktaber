import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/device.dart';
import '../../../core/models/maintenance_log.dart';
import '../../../core/models/photo_record.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/services/notification_service.dart';
import '../data/maintenance_repository.dart';
import '../../device/data/device_repository.dart';
import '../../photo/data/photo_repository.dart';

class DeviceMaintenanceScreen extends ConsumerStatefulWidget {
  final Device device;

  const DeviceMaintenanceScreen({super.key, required this.device});

  @override
  ConsumerState<DeviceMaintenanceScreen> createState() => _DeviceMaintenanceScreenState();
}

class _DeviceMaintenanceScreenState extends ConsumerState<DeviceMaintenanceScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      _showAddPhotoNoteDialog(image.path);
    }
  }

  void _showAddPhotoNoteDialog(String imagePath) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة ملاحظة للصورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(imagePath), height: 150, fit: BoxFit.cover),
            const SizedBox(height: 10),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تخطي/إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newPhoto = PhotoRecord(
                imagePath: imagePath,
                note: noteController.text.isNotEmpty ? noteController.text : null,
              );
              await ref.read(photoRepositoryProvider).addPhotoToDevice(newPhoto, widget.device);
              ref.invalidate(photosByDeviceProvider(widget.device.id));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePhoto(PhotoRecord photo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الصورة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(photoRepositoryProvider).deletePhoto(photo.id);
      ref.invalidate(photosByDeviceProvider(widget.device.id));
    }
  }

  Future<void> _confirmDeleteLog(MaintenanceLog log) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف سجل الصيانة هذا؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(maintenanceRepositoryProvider).deleteLog(log.id);
      ref.invalidate(maintenanceLogsByDeviceProvider(widget.device.id));
    }
  }

  void _showAddMaintenanceDialog() {
    final faultController = TextEditingController();
    final solutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل صيانة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: faultController, decoration: const InputDecoration(labelText: 'العطل')),
            TextField(controller: solutionController, decoration: const InputDecoration(labelText: 'الحل المتبع')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (faultController.text.isNotEmpty && solutionController.text.isNotEmpty) {
                final newLog = MaintenanceLog(
                  fault: faultController.text,
                  solution: solutionController.text,
                  maintenanceDate: DateTime.now(),
                );
                await ref.read(maintenanceRepositoryProvider).addLog(newLog, widget.device);

                // Update device next maintenance date
                final nextDate = DateTime.now().add(const Duration(days: 30));
                widget.device.nextMaintenanceDate = nextDate;
                await ref.read(deviceRepositoryProvider).updateDevice(widget.device);

                // Reschedule notification
                await NotificationService().scheduleMaintenanceNotification(
                    id: widget.device.id,
                    title: 'تذكير بصيانة: ${widget.device.name}',
                    body: 'حان موعد الصيانة الدورية للجهاز.',
                    scheduledDate: nextDate,
                );

                ref.invalidate(maintenanceLogsByDeviceProvider(widget.device.id));
                ref.invalidate(devicesByLabProvider(widget.device.lab.value!.id));

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ و إعادة جدولة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(maintenanceLogsByDeviceProvider(widget.device.id));
    final photosAsync = ref.watch(photosByDeviceProvider(widget.device.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('صيانة: ${widget.device.name}'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade50, Colors.teal.shade200],
          ),
        ),
        child: Column(
          children: [
            // Photos Section
            Container(
              height: 150,
              padding: const EdgeInsets.all(8.0),
              child: photosAsync.when(
                data: (photos) {
                  if (photos.isEmpty) return const Center(child: Text('لا توجد صور ملحقة'));
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return GestureDetector(
                        onLongPress: () => _confirmDeletePhoto(photo),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          width: 120,
                          child: GlassMorphism(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.file(
                                    File(photo.imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                if (photo.note != null)
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      photo.note!,
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Center(child: Text('خطأ في تحميل الصور')),
              ),
            ),
            const Divider(),
            // Logs Section
            Expanded(
              child: logsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Center(child: Text('لا توجد سجلات صيانة سابقة', style: TextStyle(fontSize: 16)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassMorphism(
                          child: ListTile(
                            title: Text('العطل: ${log.fault}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('الحل: ${log.solution}\nالتاريخ: ${log.maintenanceDate.toLocal().toString().split(' ')[0]}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDeleteLog(log),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('خطأ: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: _pickImage,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_log',
            onPressed: _showAddMaintenanceDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
