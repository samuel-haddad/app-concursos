import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Visualizador de PDF em tela cheia a partir de uma URL (funciona web e desktop).
class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String titulo;
  const PdfViewerScreen({super.key, required this.url, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SfPdfViewer.network(url),
    );
  }
}
