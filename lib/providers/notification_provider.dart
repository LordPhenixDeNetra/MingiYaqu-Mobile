import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _boxName = 'notification_settings';
  static const String _settingsKey = 'settings';
  
  Box? _box;
  NotificationSettings _settings = NotificationSettings();
  final NotificationService _notificationService = NotificationService();

  NotificationSettings get settings => _settings;
  bool get isEnabled => _settings.isEnabled;
  List<int> get reminderDays => _settings.reminderDays;
  String get formattedTime => _settings.formattedTime;

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      await _notificationService.init();
      _loadSettings();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du NotificationProvider: $e');
    }
  }

  // Méthode d'initialisation pour MultiProvider
  Future<void> initialize() async {
    await init();
  }

  void _loadSettings() {
    if (_box != null) {
      final savedSettings = _box!.get(_settingsKey);
      if (savedSettings != null && savedSettings is NotificationSettings) {
        _settings = savedSettings;
      }
      notifyListeners();
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    
    // Mettre à jour les notifications programmées
    if (_settings.isEnabled) {
      await _notificationService.scheduleNotifications(_settings);
    } else {
      await _notificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    final newSettings = _settings.copyWith(isEnabled: !_settings.isEnabled);
    await updateSettings(newSettings);
  }

  Future<void> setReminderDays(List<int> days) async {
    final newSettings = _settings.copyWith(reminderDays: days);
    await updateSettings(newSettings);
  }

  Future<void> setReminderTime(int hour, int minute) async {
    final newSettings = _settings.copyWith(
      reminderHour: hour,
      reminderMinute: minute,
    );
    await updateSettings(newSettings);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(soundEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(vibrationEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> _saveSettings() async {
    try {
      await _box?.put(_settingsKey, _settings);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des paramètres de notification: $e');
    }
  }

  // Vérifier les permissions de notification
  Future<bool> checkPermissions() async {
    return await _notificationService.checkPermissions();
  }

  // Demander les permissions de notification
  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  // Tester une notification
  Future<void> showTestNotification() async {
    await _notificationService.showTestNotification();
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}