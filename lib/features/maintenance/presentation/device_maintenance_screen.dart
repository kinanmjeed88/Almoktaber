import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import "../../photo/presentation/full_screen_image_viewer.dart";

import '../../../core/models/device.dart';
import '../../../core/models/maintenance_log.dart';
import '../../../core/models/photo_record.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/glassmorphism.dart';
import '../data/maintenance_repository.dart';
import '../../device/data/device_repository.dart';
import '../../photo/data/photo_repository.dart';
import '../../../features/dashboard/analytics_screen.dart';

class DeviceMaintenanceScreen extends ConsumerStatefulWidget {
  final Device device;

  const DeviceMaintenanceScreen({super.key, required this.device});

  @override
  ConsumerState<DeviceMaintenanceScreen> createState() => _DeviceMaintenanceScreenState();
}

class _DeviceMaintenanceScreenState extends ConsumerState<DeviceMaintenanceScreen> {
  int? _expandedLogId;

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
      ref.invalidate(analyticsProvider);
    }
  }

  void _showAddMaintenanceDialog({MaintenanceLog? log}) {
    final faultController = TextEditingController(text: log?.fault ?? '');
    final solutionController = TextEditingController(text: log?.solution ?? '');
    File? selectedImage;
    PhotoRecord? existingPhoto;
    bool isInit = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          if (isInit && log != null) {
            isInit = false;
            ref.read(photoRepositoryProvider).getPhotosByLogId(log.id).then((photos) {
              if (photos.isNotEmpty && context.mounted) {
                setState(() {
                  existingPhoto = photos.first;
                  selectedImage = File(existingPhoto!.imagePath);
                });
              }
            });
          } else if (isInit) {
             isInit = false;
          }
          return AlertDialog(
          title: Text(log == null ? 'تسجيل صيانة جديدة' : 'تعديل صيانة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: faultController, decoration: const InputDecoration(labelText: 'العطل')),
              TextField(controller: solutionController, decoration: const InputDecoration(labelText: 'الحل المتبع')),
              const SizedBox(height: 12),
              if (selectedImage != null)
                Image.file(selectedImage!, height: 100, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      selectedImage = File(pickedFile.path);
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('إرفاق صورة (اختياري)'),
              ),
            ],
          ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (faultController.text.isNotEmpty && solutionController.text.isNotEmpty) {
                try {
                  MaintenanceLog targetLog;
                  if (log != null) {
                    log.fault = faultController.text;
                    log.solution = solutionController.text;
                    await ref.read(maintenanceRepositoryProvider).updateLog(log);
                    targetLog = log;
                  } else {
                    final newLog = MaintenanceLog(
                      fault: faultController.text,
                      solution: solutionController.text,
                      maintenanceDate: DateTime.now(),
                    );
                    await ref.read(maintenanceRepositoryProvider).addLog(newLog, widget.device);
                    targetLog = newLog;
                  }

                  if (selectedImage != null && (existingPhoto == null || selectedImage!.path != existingPhoto!.imagePath)) {
                    if (existingPhoto != null) {
                      await ref.read(photoRepositoryProvider).deletePhoto(existingPhoto!.id);
                    }

                    final directory = await getApplicationDocumentsDirectory();
                    final imageId = const Uuid().v4();
                    final String path = '${directory.path}/$imageId.jpg';
                    final savedImage = await selectedImage!.copy(path);

                    final photo = PhotoRecord(
                      imagePath: savedImage.path,
                      note: 'صيانة: ${targetLog.fault}',
                    );
                    await ref.read(photoRepositoryProvider).addPhotoToLog(photo, targetLog);
                  }

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
                  ref.invalidate(analyticsProvider);

                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الصيانة بنجاح')));
                  }
                } catch (e) {
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                }
              }
            },
            child: const Text('حفظ و إعادة جدولة'),
          ),
        ],
        );
      },
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
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)],
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
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
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
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _expandedLogId = _expandedLogId == log.id ? null : log.id;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Consumer(
                                        builder: (context, ref, _) {
                                          return FutureBuilder<List<PhotoRecord>>(
                                            future: ref.read(photoRepositoryProvider).getPhotosByLogId(log.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => FullScreenImageViewer(
                                                          imagePath: snapshot.data!.first.imagePath,
                                                          note: snapshot.data!.first.note,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 12.0),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.file(File(snapshot.data!.first.imagePath), width: 50, height: 50, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          'العطل: ${log.fault}',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
                                            onPressed: () => _showAddMaintenanceDialog(log: log),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDeleteLog(log),
                                          ),
                                          Icon(
                                            _expandedLogId == log.id ? Icons.expand_less : Icons.expand_more,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (_expandedLogId == log.id) ...[
                                    const SizedBox(height: 8),
                                    Text('الحل: ${log.solution}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    const SizedBox(height: 4),
                                    Text('التاريخ: ${log.maintenanceDate.toLocal().toString().split(' ')[0]}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                ],
                              ),
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
            heroTag: 'add_log',
            onPressed: () => _showAddMaintenanceDialog(),
            child: const Icon(Icons.add),
          ),
        ],
      ),

    );
  }
}
