import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkMode';
  
  Box? _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      _loadTheme();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du ThemeProvider: $e');
    }
  }

  // Méthode d'initialisation pour MultiProvider
  Future<void> initialize() async {
    await init();
  }

  void _loadTheme() {
    if (_box != null) {
      _isDarkMode = _box!.get(_themeKey, defaultValue: false);
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveTheme();
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    try {
      await _box?.put(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
    }
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}