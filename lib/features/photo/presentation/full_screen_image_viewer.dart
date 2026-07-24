import 'package:flutter/material.dart';
import 'dart:io';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String? note;

  const FullScreenImageViewer({super.key, required this.imagePath, this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (note != null && note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.black54,
                child: Text(
                  note!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
