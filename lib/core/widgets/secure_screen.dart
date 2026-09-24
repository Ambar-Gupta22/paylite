import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class SecureScreen extends StatefulWidget {
  final Widget child;

  const SecureScreen({super.key, required this.child});

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    _secureScreen();
  }

  @override
  void dispose() {
    _unsecureScreen();
    super.dispose();
  }

  Future<void> _secureScreen() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        // Ignore errors if plugin fails
      }
    }
  }

  Future<void> _unsecureScreen() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        // Ignore errors if plugin fails
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
