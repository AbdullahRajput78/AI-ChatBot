import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final String pdfPath;
  final String title;

  const PdfPreviewPage({Key? key, required this.pdfPath, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    final fileName = '${safeTitle.isEmpty ? 'Chat Export' : safeTitle}.pdf';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) async {
          try {
            final file = File(pdfPath);
            if (!await file.exists()) return Uint8List(0);
            return await file.readAsBytes();
          } catch (_) {
            return Uint8List(0);
          }
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowSharing: true,
        allowPrinting: true,
        pdfFileName: fileName,
      ),
    );
  }
}