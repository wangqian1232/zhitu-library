import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class SystemSettings {
  int borrowDays;
  int renewCount;
  double overdueFine;
  int maxBorrowCount;

  SystemSettings({
    this.borrowDays = 30,
    this.renewCount = 1,
    this.overdueFine = 0.5,
    this.maxBorrowCount = 5,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      borrowDays: json['borrowDays'] ?? 30,
      renewCount: json['renewCount'] ?? 1,
      overdueFine: (json['overdueFine'] ?? 0.5).toDouble(),
      maxBorrowCount: json['maxBorrowCount'] ?? 5,
    );
  }
}

class SystemSettingsService {
  static final SystemSettingsService _instance = SystemSettingsService._internal();
  factory SystemSettingsService() => _instance;
  SystemSettingsService._internal();

  SystemSettings _settings = SystemSettings();
  bool _initialized = false;

  SystemSettings get settings => _settings;

  Future<void> loadSettings() async {
    if (_initialized) return;
    try {
      final response = await http.get(Uri.parse('${AppConfig.getBaseUrl()}/settings'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _settings = SystemSettings.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
    _initialized = true;
  }

  Future<void> updateBorrowDays(int days) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.getBaseUrl()}/settings/borrow-days'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'borrowDays': days}),
      );
      if (response.statusCode == 200) {
        _settings.borrowDays = days;
      }
    } catch (e) {
      print('Failed to update borrow days: $e');
    }
  }

  Future<void> updateRenewCount(int count) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.getBaseUrl()}/settings/renew-count'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'renewCount': count}),
      );
      if (response.statusCode == 200) {
        _settings.renewCount = count;
      }
    } catch (e) {
      print('Failed to update renew count: $e');
    }
  }

  Future<void> updateOverdueFine(double fine) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.getBaseUrl()}/settings/overdue-fine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'overdueFine': fine}),
      );
      if (response.statusCode == 200) {
        _settings.overdueFine = fine;
      }
    } catch (e) {
      print('Failed to update overdue fine: $e');
    }
  }

  Future<void> updateMaxBorrowCount(int count) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.getBaseUrl()}/settings/max-borrow-count'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'maxBorrowCount': count}),
      );
      if (response.statusCode == 200) {
        _settings.maxBorrowCount = count;
      }
    } catch (e) {
      print('Failed to update max borrow count: $e');
    }
  }
}
