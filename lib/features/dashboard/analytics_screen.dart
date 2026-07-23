import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/lab.dart';
import '../../core/models/device.dart';
import '../../core/models/maintenance_log.dart';
import '../../core/providers/db_provider.dart';
import '../../core/theme/glassmorphism.dart';

final analyticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final isar = ref.watch(isarProvider);
  final totalLabs = await isar.labs.count();
  final totalDevices = await isar.devices.count();
  final totalLogs = await isar.maintenanceLogs.count();

  final avgDevicesPerLab = totalLabs > 0 ? (totalDevices / totalLabs).round() : 0;

  return {
    'totalLabs': totalLabs,
    'totalDevices': totalDevices,
    'totalLogs': totalLogs,
    'avgDevicesPerLab': avgDevicesPerLab,
  };
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات النظام'),
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
        padding: const EdgeInsets.all(16),
        child: analyticsAsync.when(
          data: (data) {
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(context, 'إجمالي المختبرات', data['totalLabs'] ?? 0, Icons.business),
                _buildStatCard(context, 'إجمالي الأجهزة', data['totalDevices'] ?? 0, Icons.devices),
                _buildStatCard(context, 'سجلات الصيانة', data['totalLogs'] ?? 0, Icons.build),
                _buildStatCard(context, 'متوسط الأجهزة لكل مختبر', data['avgDevicesPerLab'] ?? 0, Icons.analytics),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('خطأ في تحميل الإحصائيات: $e', style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int value, IconData icon) {
    return GlassMorphism(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
