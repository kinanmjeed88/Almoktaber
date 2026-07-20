import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glassmorphism.dart';
import '../../lab/presentation/labs_screen.dart';
import '../../maintenance/presentation/maintenance_screen.dart';
import '../excel_service.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labsAsync = ref.watch(labsProvider);
    final logsAsync = ref.watch(maintenanceLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصاءات'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade100, Colors.purple.shade400],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  GlassMorphism(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('إجمالي المختبرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        labsAsync.maybeWhen(
                          data: (labs) => Text('${labs.length}', style: const TextStyle(fontSize: 32)),
                          orElse: () => const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                  GlassMorphism(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('سجلات الصيانة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        logsAsync.maybeWhen(
                          data: (logs) => Text('${logs.length}', style: const TextStyle(fontSize: 32)),
                          orElse: () => const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(excelServiceProvider).exportToExcel(context);
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('تصدير إلى Excel'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
