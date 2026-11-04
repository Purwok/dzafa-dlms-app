import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const DzafaDlmsApp());
}

class DzafaDlmsApp extends StatelessWidget {
  const DzafaDlmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DZAFA DLMS',
      home: DlmsWebViewScreen(),
    );
  }
}

class DlmsWebViewScreen extends StatefulWidget {
  const DlmsWebViewScreen({super.key});

  @override
  State<DlmsWebViewScreen> createState() => _DlmsWebViewScreenState();
}

class _DlmsWebViewScreenState extends State<DlmsWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Mengarahkan WebView langsung ke alamat Web UI ESP32-S3
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E1E1E))
      ..loadRequest(Uri.parse('http://192.168.4.1'));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}