import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/device.dart';
import '../../../core/models/lab.dart';
import '../data/device_repository.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  final Lab lab;

  const AddDeviceScreen({super.key, required this.lab});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _testsCountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _creationDate = DateTime.now();
  DateTime _nextMaintenanceDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _phoneController.dispose();
    _materialCostController.dispose();
    _testsCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  void _saveDevice() async {
    if (_formKey.currentState!.validate()) {
      final newDevice = Device(
        name: _nameController.text,
        type: _typeController.text,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        phoneNumber: _phoneController.text,
        materialCost: double.tryParse(_materialCostController.text) ?? 0.0,
        testsCount: int.tryParse(_testsCountController.text) ?? 0,
        creationDate: _creationDate,
        nextMaintenanceDate: _nextMaintenanceDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await ref.read(deviceRepositoryProvider).addDevice(newDevice, widget.lab);
      ref.invalidate(devicesByLabProvider(widget.lab.id));

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة جهاز'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الجهاز', filled: true, fillColor: Colors.white70),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال اسم الجهاز' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'نوع الجهاز', filled: true, fillColor: Colors.white70),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال نوع الجهاز' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'العدد', filled: true, fillColor: Colors.white70),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', filled: true, fillColor: Colors.white70),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _materialCostController,
                  decoration: const InputDecoration(labelText: 'سعر المواد', filled: true, fillColor: Colors.white70),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _testsCountController,
                  decoration: const InputDecoration(labelText: 'عدد الفحوصات', filled: true, fillColor: Colors.white70),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white70,
                  title: const Text('تاريخ الإنشاء'),
                  subtitle: Text(_creationDate.toLocal().toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, _creationDate, (date) => setState(() => _creationDate = date)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'الملاحظات', filled: true, fillColor: Colors.white70),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white70,
                  title: const Text('موعد الصيانة الدورية'),
                  subtitle: Text(_nextMaintenanceDate.toLocal().toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, _nextMaintenanceDate, (date) => setState(() => _nextMaintenanceDate = date)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveDevice,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('حفظ الجهاز', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
