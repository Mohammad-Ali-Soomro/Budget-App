import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static late Box _settingsBox;

  static Future<void> init() async {
    // For now, just open a simple settings box to avoid adapter issues
    _settingsBox = await Hive.openBox('settings');
  }

  // Simplified initialization - no default data for now

  // Getters for boxes
  static Box get settingsBox => _settingsBox;

  // Close all boxes
  static Future<void> closeBoxes() async {
    await _settingsBox.close();
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await _settingsBox.clear();
  }
}
