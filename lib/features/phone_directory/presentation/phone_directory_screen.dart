import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import "package:isar/isar.dart";

import '../../../core/models/phone_record.dart';
import '../../../core/providers/db_provider.dart';
import '../../../core/theme/glassmorphism.dart';

final phoneRecordsProvider = FutureProvider<List<PhoneRecord>>((ref) async {
  final isar = ref.watch(isarProvider);
  // Watch for any changes
  ref.watch(refreshProvider);
  return await isar.phoneRecords.where().findAll();
});

final phoneSearchQueryProvider = StateProvider<String>((ref) => '');

class PhoneDirectoryScreen extends ConsumerStatefulWidget {
  const PhoneDirectoryScreen({super.key});

  @override
  ConsumerState<PhoneDirectoryScreen> createState() => _PhoneDirectoryScreenState();
}

class _PhoneDirectoryScreenState extends ConsumerState<PhoneDirectoryScreen> {
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  void _onSort(int columnIndex, bool ascending, List<PhoneRecord> data, WidgetRef ref) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phoneRecordsAsync = ref.watch(phoneRecordsProvider);
    final searchQuery = ref.watch(phoneSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الهواتف'),
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
                  onChanged: (value) => ref.read(phoneSearchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'البحث عن جهة، هاتف أو محافظة...',
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
              child: phoneRecordsAsync.when(
                data: (records) {
                  var filteredRecords = records.where((record) {
                    final query = searchQuery.toLowerCase();
                    return record.labName.toLowerCase().contains(query) ||
                           record.phoneNumber.toLowerCase().contains(query) ||
                           record.province.toLowerCase().contains(query);
                  }).toList();

                  if (filteredRecords.isEmpty) {
                    return const Center(child: Text('لا توجد سجلات مطابقة', style: TextStyle(fontSize: 18)));
                  }

                  // Sorting logic
                  filteredRecords.sort((a, b) {
                    int compareResult = 0;
                    if (_sortColumnIndex == 1) {
                      compareResult = a.labName.compareTo(b.labName);
                    } else if (_sortColumnIndex == 2) {
                      compareResult = a.phoneNumber.compareTo(b.phoneNumber);
                    } else if (_sortColumnIndex == 3) {
                      compareResult = a.province.compareTo(b.province);
                    } else {
                       compareResult = a.id.compareTo(b.id);
                    }
                    return _isAscending ? compareResult : -compareResult;
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _isAscending,
                        columns: [
                          DataColumn(
                            label: const Text('التسلسل', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending, filteredRecords, ref),
                          ),
                          DataColumn(
                            label: const Text('اسم المختبر/الجهة', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending, filteredRecords, ref),
                          ),
                          DataColumn(
                            label: const Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending, filteredRecords, ref),
                          ),
                          DataColumn(
                            label: const Text('المحافظة', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending, filteredRecords, ref),
                          ),
                        ],
                        rows: filteredRecords.asMap().entries.map((entry) {
                          int index = entry.key;
                          PhoneRecord record = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text(record.labName)),
                              DataCell(
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: record.phoneNumber));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الهاتف')));
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(record.phoneNumber, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.copy, size: 16, color: Colors.blue),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(record.province)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
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
        onPressed: () => _showAddRecordDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final provinceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة جهة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم/الجهة')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
            TextField(controller: provinceController, decoration: const InputDecoration(labelText: 'المحافظة')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty && provinceController.text.isNotEmpty) {
                try {
                  final isar = ref.read(isarProvider);
                  final newRecord = PhoneRecord(
                    labName: nameController.text,
                    phoneNumber: phoneController.text,
                    province: provinceController.text,
                  );
                  await isar.writeTxn(() async {
                    await isar.phoneRecords.put(newRecord);
                  });
                  ref.invalidate(phoneRecordsProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));
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
