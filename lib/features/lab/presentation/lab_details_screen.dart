import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../../core/models/lab.dart';
import '../../../core/models/device.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/services/notification_service.dart';
import '../../device/data/device_repository.dart';
import '../../device/presentation/add_device_screen.dart';
import '../../maintenance/presentation/device_maintenance_screen.dart';
import '../../../features/dashboard/analytics_screen.dart';
import '../../photo/data/photo_repository.dart';
import '../../photo/presentation/full_screen_image_viewer.dart';

final devicesSearchQueryProvider = StateProvider.family<String, int>((ref, labId) => '');

class LabDetailsScreen extends ConsumerStatefulWidget {
  final Lab lab;

  const LabDetailsScreen({super.key, required this.lab});

  @override
  ConsumerState<LabDetailsScreen> createState() => _LabDetailsScreenState();
}

class _LabDetailsScreenState extends ConsumerState<LabDetailsScreen> {
  int? _expandedDeviceId;

  @override
  Widget build(BuildContext context) {
    final lab = widget.lab;
    final devicesAsync = ref.watch(devicesByLabProvider(lab.id));
    final searchQuery = ref.watch(devicesSearchQueryProvider(lab.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('أجهزة المختبر: ${lab.name}'),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassMorphism(
                child: TextField(
                  onChanged: (value) => ref.read(devicesSearchQueryProvider(lab.id).notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'البحث عن جهاز (الاسم، تاريخ)...',
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            Expanded(
              child: devicesAsync.when(
                data: (devices) {
                  final filteredDevices = devices.where((device) {
                    final query = searchQuery.toLowerCase();
                    return device.name.toLowerCase().contains(query) ||
                           device.creationDate.toLocal().toString().contains(query) ||
                           device.nextMaintenanceDate.toLocal().toString().contains(query);
                  }).toList();

                  if (filteredDevices.isEmpty) {
                    return const Center(child: Text('لا توجد أجهزة مطابقة للبحث', style: TextStyle(fontSize: 18)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassMorphism(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _expandedDeviceId = _expandedDeviceId == device.id ? null : device.id;
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
                                          final photosAsync = ref.watch(photosByDeviceProvider(device.id));
                                          return photosAsync.when(
                                            data: (photos) {
                                              if (photos.isNotEmpty) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => FullScreenImageViewer(
                                                          imagePath: photos.first.imagePath,
                                                          note: photos.first.note,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 12.0),
                                                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(photos.first.imagePath), width: 50, height: 50, fit: BoxFit.cover)),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                            loading: () => const SizedBox.shrink(),
                                            error: (e, st) => const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          device.name,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
                                            tooltip: 'الصيانة والتفاصيل',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DeviceMaintenanceScreen(device: device),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddDeviceScreen(lab: lab, device: device),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDeleteDevice(context, ref, device),
                                          ),
                                          Icon(
                                            _expandedDeviceId == device.id ? Icons.expand_less : Icons.expand_more,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('النوع: ${device.type} | العدد: ${device.quantity}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                  if (_expandedDeviceId == device.id) ...[
                                    Text('رقم الهاتف: ${device.phoneNumber}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    Text('سعر المواد: ${device.materialCost}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    Text('عدد الفحوصات: ${device.testsCount}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    Text('تاريخ الإنشاء: ${device.creationDate.toLocal().toString().split(' ')[0]}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    Text('موعد الصيانة القادم: ${device.nextMaintenanceDate.toLocal().toString().split(' ')[0]}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    if (device.notes != null && device.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text('ملاحظات: ${device.notes}', style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface)),
                                    ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDeviceScreen(lab: lab),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDeleteDevice(BuildContext context, WidgetRef ref, Device device) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الجهاز "${device.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref.read(deviceRepositoryProvider).deleteDevice(device.id);
        NotificationService().cancelNotification(device.id);
        ref.invalidate(devicesByLabProvider(widget.lab.id));
        ref.invalidate(analyticsProvider);
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الجهاز بنجاح')));
        }
      } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')));
        }
      }
    }
  }

}
