import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../camera/presentation/camera_screen.dart';
import '../lab/presentation/labs_screen.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/services/notification_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم - إدارة المختبرات'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade100, Colors.blueGrey.shade400],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGridItem(
              context,
              title: 'المختبرات والأجهزة',
              icon: Icons.science,
              color: Colors.teal,
              screen: const LabsScreen(),
            ),
            _buildGridItem(
              context,
              title: 'الكاميرا الحرة',
              icon: Icons.camera_alt,
              color: Colors.blue,
              screen: const CameraScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, {required String title, required IconData icon, required Color color, required Widget screen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: GlassMorphism(
        color: color.withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
