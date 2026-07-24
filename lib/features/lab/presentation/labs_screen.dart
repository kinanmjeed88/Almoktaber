import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lab.dart';
import '../../../core/theme/glassmorphism.dart';
import '../data/lab_repository.dart';
import 'lab_details_screen.dart';
import '../../../features/dashboard/analytics_screen.dart';

class LabsScreen extends ConsumerWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labsAsync = ref.watch(labsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المختبرات'),
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
        child: labsAsync.when(
          data: (labs) {
            if (labs.isEmpty) {
              return const Center(child: Text('لا توجد مختبرات مسجلة', style: TextStyle(fontSize: 18)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: labs.length,
              itemBuilder: (context, index) {
                final lab = labs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassMorphism(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LabDetailsScreen(lab: lab),
                          ),
                        );
                      },
                      title: Text(lab.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: Text('الموقع: ${lab.location}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () {
                              _showAddLabDialog(context, ref, lab: lab);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteLab(context, ref, lab),
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
          error: (e, st) => Center(child: Text('خطأ: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLabDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDeleteLab(BuildContext context, WidgetRef ref, Lab lab) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المختبر "${lab.name}"؟ سيتم حذف جميع الأجهزة المرتبطة به أيضاً.'),
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
        await ref.read(labRepositoryProvider).deleteLab(lab.id);
        ref.invalidate(labsProvider);
        ref.invalidate(analyticsProvider);
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المختبر بنجاح')));
        }
      } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')));
        }
      }
    }
  }

  void _showAddLabDialog(BuildContext context, WidgetRef ref, {Lab? lab}) {
    final nameController = TextEditingController(text: lab?.name ?? '');
    final locationController = TextEditingController(text: lab?.location ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lab == null ? 'إضافة مختبر جديد' : 'تعديل المختبر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المختبر')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'الموقع')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                try {
                  final newLab = Lab(
                    name: nameController.text,
                    location: locationController.text,
                  );
                  if (lab != null) {
                    newLab.id = lab.id;
                    await ref.read(labRepositoryProvider).updateLab(newLab);
                  } else {
                    await ref.read(labRepositoryProvider).addLab(newLab);
                  }
                  ref.invalidate(labsProvider);
                  ref.invalidate(analyticsProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المختبر بنجاح')));
                  }
                } catch (e) {
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
