import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lab.dart';
import '../../../core/models/device.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/services/notification_service.dart';
import '../../device/data/device_repository.dart';
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
          _showAddDeviceDialog(context, ref);
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

  void _showAddDeviceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final quantityController = TextEditingController();
    final phoneController = TextEditingController();
    final materialCostController = TextEditingController();
    final testsCountController = TextEditingController();
    final notesController = TextEditingController();

    DateTime nextMaintenance = DateTime.now().add(const Duration(days: 30));
    int intervalMonths = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة جهاز جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الجهاز')),
                TextField(controller: typeController, decoration: const InputDecoration(labelText: 'نوع الجهاز')),
                TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'العدد'), keyboardType: TextInputType.number),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف للتواصل'), keyboardType: TextInputType.phone),
                TextField(controller: materialCostController, decoration: const InputDecoration(labelText: 'تكلفة المواد'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                TextField(controller: testsCountController, decoration: const InputDecoration(labelText: 'عدد الفحوصات'), keyboardType: TextInputType.number),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'ملاحظات إضافية')),
                const SizedBox(height: 16),
                const Text('إعدادات الصيانة', style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('فترة الصيانة (بالأشهر)'),
                  trailing: DropdownButton<int>(
                    value: intervalMonths,
                    items: [1, 3, 6, 12].map((m) => DropdownMenuItem(value: m, child: Text('$m شهر'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          intervalMonths = val;
                          nextMaintenance = DateTime.now().add(Duration(days: val * 30));
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('موعد الصيانة القادم'),
                  subtitle: Text(nextMaintenance.toLocal().toString().split(' ')[0]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && typeController.text.isNotEmpty) {
                  final newDevice = Device(
                    name: nameController.text,
                    type: typeController.text,
                    quantity: int.tryParse(quantityController.text) ?? 1,
                    phoneNumber: phoneController.text,
                    materialCost: double.tryParse(materialCostController.text) ?? 0.0,
                    testsCount: int.tryParse(testsCountController.text) ?? 0,
                    creationDate: DateTime.now(),
                    notes: notesController.text.isEmpty ? null : notesController.text,
                    nextMaintenanceDate: nextMaintenance,
                    maintenanceIntervalMonths: intervalMonths,
                  );

                  await ref.read(deviceRepositoryProvider).addDevice(newDevice, lab);

                  await NotificationService().scheduleMaintenanceNotification(
                    id: newDevice.id,
                    title: 'تذكير بصيانة: ${newDevice.name}',
                    body: 'حان موعد الصيانة الدورية للجهاز الموجود في ${lab.name}.',
                    scheduledDate: newDevice.nextMaintenanceDate,
                  );

                  ref.invalidate(devicesByLabProvider(lab.id));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
