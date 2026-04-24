import 'dart:async';
import 'package:flutter/foundation.dart';

class MockBackend {
  MockBackend._();
  static final MockBackend instance = MockBackend._();

  // Simulated Database for Reports
  final List<Map<String, dynamic>> _reports = [];
  
  // Stream to listen for news updates
  final _newsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get newsStream => _newsController.stream;

  Future<bool> submitReport(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    _reports.add({
      ...data,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'Pending Review',
    });
    debugPrint("Backend: Report received - ${data['headline']}");
    return true;
  }

  Future<Map<String, dynamic>> scanSystem() async {
    await Future.delayed(const Duration(seconds: 3));
    return {
      'threatsFound': 2,
      'riskyApps': ['FakeLoan_v2', 'ScreenMirror_Pro'],
      'status': 'Action Required',
      'scanTime': DateTime.now().toIso8601String(),
    };
  }

  Future<void> freezeBank() async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint("Backend: Bank Freeze Signal Sent Successfully");
  }

  void dispose() {
    _newsController.close();
  }
}
