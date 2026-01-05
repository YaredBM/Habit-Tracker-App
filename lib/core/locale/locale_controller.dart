import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'forced_locale_code';

  Locale? _locale; // null => follow system
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    _locale = (code == null || code.isEmpty) ? null : Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();

    if (locale == null) {
      await prefs.remove(_prefsKey); // follow system
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
    notifyListeners();
  }
}


final localeController = LocaleController();