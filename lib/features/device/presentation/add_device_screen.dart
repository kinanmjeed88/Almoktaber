import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/device.dart';
import '../../../core/models/lab.dart';
import '../data/device_repository.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  final Lab lab;
  final Device? device;

  const AddDeviceScreen({super.key, required this.lab, this.device});

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
  void initState() {
    super.initState();
    if (widget.device != null) {
      _nameController.text = widget.device!.name;
      _typeController.text = widget.device!.type;
      _quantityController.text = widget.device!.quantity.toString();
      _phoneController.text = widget.device!.phoneNumber;
      _materialCostController.text = widget.device!.materialCost.toString();
      _testsCountController.text = widget.device!.testsCount.toString();
      _notesController.text = widget.device!.notes ?? '';
      _creationDate = widget.device!.creationDate;
      _nextMaintenanceDate = widget.device!.nextMaintenanceDate;
    }
  }

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
      try {
        if (widget.device != null) {
          widget.device!.name = _nameController.text;
          widget.device!.type = _typeController.text;
          widget.device!.quantity = int.tryParse(_quantityController.text) ?? 1;
          widget.device!.phoneNumber = _phoneController.text;
          widget.device!.materialCost = double.tryParse(_materialCostController.text) ?? 0.0;
          widget.device!.testsCount = int.tryParse(_testsCountController.text) ?? 0;
          widget.device!.creationDate = _creationDate;
          widget.device!.nextMaintenanceDate = _nextMaintenanceDate;
          widget.device!.notes = _notesController.text.isEmpty ? null : _notesController.text;

          await ref.read(deviceRepositoryProvider).updateDevice(widget.device!);
        } else {
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
        }

        ref.invalidate(devicesByLabProvider(widget.lab.id));

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
        }
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
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)],
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
                  decoration: InputDecoration(labelText: 'اسم الجهاز', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال اسم الجهاز' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _typeController,
                  decoration: InputDecoration(labelText: 'نوع الجهاز', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال نوع الجهاز' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'العدد', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'رقم الهاتف', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _materialCostController,
                  decoration: InputDecoration(labelText: 'سعر المواد', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _testsCountController,
                  decoration: InputDecoration(labelText: 'عدد الفحوصات', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  title: const Text('تاريخ الإنشاء'),
                  subtitle: Text(_creationDate.toLocal().toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, _creationDate, (date) => setState(() => _creationDate = date)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'الملاحظات', filled: true, fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
