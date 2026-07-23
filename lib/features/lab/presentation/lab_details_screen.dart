import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lab.dart';
import '../../../core/models/device.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/services/notification_service.dart';
import '../../device/data/device_repository.dart';
import '../../device/presentation/add_device_screen.dart';
import '../../maintenance/presentation/device_maintenance_screen.dart';

class LabDetailsScreen extends ConsumerWidget {
  final Lab lab;

  const LabDetailsScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesByLabProvider(lab.id));

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
            colors: [Colors.teal.shade50, Colors.teal.shade200],
          ),
        ),
        child: devicesAsync.when(
          data: (devices) {
            if (devices.isEmpty) {
              return const Center(child: Text('لا توجد أجهزة مضافة لهذا المختبر', style: TextStyle(fontSize: 18)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassMorphism(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceMaintenanceScreen(device: device),
                          ),
                        );
                      },
                      title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('النوع: ${device.type} | العدد: ${device.quantity}\nموعد الصيانة القادم: ${device.nextMaintenanceDate.toLocal().toString().split(' ')[0]}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteDevice(context, ref, device),
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
      await ref.read(deviceRepositoryProvider).deleteDevice(device.id);
      NotificationService().cancelNotification(device.id);
      ref.invalidate(devicesByLabProvider(lab.id));
    }
  }

}
