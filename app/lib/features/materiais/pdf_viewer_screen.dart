import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Visualizador de PDF em tela cheia (arquivo local do computador).
/// Usa o SfPdfViewer (renderização em Dart puro, sem build nativo).
class PdfViewerScreen extends StatelessWidget {
  final String path;
  final String titulo;
  const PdfViewerScreen({super.key, required this.path, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final existe = File(path).existsSync();
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: existe
          ? SfPdfViewer.file(File(path))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Arquivo não encontrado:\n$path',
                    textAlign: TextAlign.center),
              ),
            ),
    );
  }
}
