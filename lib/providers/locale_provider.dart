import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';
  
  Box? _box;
  Locale _locale = const Locale('fr'); // Français par défaut

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  String get currentLanguage => _locale.languageCode;
  bool get isFrench => _locale.languageCode == 'fr';
  bool get isEnglish => _locale.languageCode == 'en';

  // Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr'), // Français
    Locale('en'), // Anglais
  ];

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      _loadLocale();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du LocaleProvider: $e');
    }
  }

  // Méthode d'initialisation pour MultiProvider
  Future<void> initialize() async {
    await init();
  }

  void _loadLocale() {
    if (_box != null) {
      final savedLanguageCode = _box!.get(_localeKey, defaultValue: 'fr');
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale != locale && supportedLocales.contains(locale)) {
      _locale = locale;
      await _saveLocale();
      notifyListeners();
    }
  }

  Future<void> setLanguageCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = _locale.languageCode == 'fr' ? 'en' : 'fr';
    await setLanguageCode(newLanguageCode);
  }

  Future<void> _saveLocale() async {
    try {
      await _box?.put(_localeKey, _locale.languageCode);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la langue: $e');
    }
  }

  // Obtenir le nom de la langue dans la langue actuelle
  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }

  // Obtenir le nom de l'autre langue
  String getOtherLanguageName() {
    switch (_locale.languageCode) {
      case 'fr':
        return 'English';
      case 'en':
        return 'Français';
      default:
        return 'English';
    }
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}