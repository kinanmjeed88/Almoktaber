import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/maintenance_log.dart';
import '../../../core/providers/db_provider.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../lab/data/lab_repository.dart';
import '../data/maintenance_repository.dart';

final maintenanceLogsProvider = FutureProvider<List<MaintenanceLog>>((ref) async {
  ref.watch(refreshProvider); // watch for restore updates
  final repository = ref.read(maintenanceRepositoryProvider);
  return repository.getAllLogs();
});

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(maintenanceLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجلات الصيانة'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.orange.shade100, Colors.orange.shade400],
          ),
        ),
        child: logsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(child: Text('لا توجد سجلات صيانة', style: TextStyle(fontSize: 18)));
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
                      title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${log.description}\nالتاريخ: ${log.date.toLocal().toString().split(' ')[0]}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () {
                              _showAddLogDialog(context, ref, log: log);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              await ref.read(maintenanceRepositoryProvider).deleteLog(log.id);
                              ref.invalidate(maintenanceLogsProvider);
                            },
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
          _showAddLogDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLogDialog(BuildContext context, WidgetRef ref, {MaintenanceLog? log}) async {
    final titleController = TextEditingController(text: log?.title ?? '');
    final descController = TextEditingController(text: log?.description ?? '');

    final labs = await ref.read(labRepositoryProvider).getAllLabs();
    if (labs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إضافة مختبر أولاً')));
      }
      return;
    }

    int selectedLabId = log?.labId ?? labs.first.id;

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(log == null ? 'إضافة سجل صيانة' : 'تعديل السجل'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'العنوان')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'الوصف')),
                DropdownButton<int>(
                  value: selectedLabId,
                  isExpanded: true,
                  items: labs.map((lab) => DropdownMenuItem(value: lab.id, child: Text(lab.name))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedLabId = val);
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                    final newLog = MaintenanceLog(
                      title: titleController.text,
                      description: descController.text,
                      date: log?.date ?? DateTime.now(),
                      labId: selectedLabId,
                    );
                    if (log != null) {
                        newLog.id = log.id;
                        await ref.read(maintenanceRepositoryProvider).updateLog(newLog);
                    } else {
                        await ref.read(maintenanceRepositoryProvider).addLog(newLog);
                    }
                    ref.invalidate(maintenanceLogsProvider);
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
}
