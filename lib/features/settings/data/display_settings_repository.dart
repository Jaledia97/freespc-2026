import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimeFormat {
  h12, // 12-hour (AM/PM)
  h24  // 24-hour
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Must be overridden in main
});

final displaySettingsRepositoryProvider = Provider<DisplaySettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DisplaySettingsRepository(prefs);
});

enum AppThemeMode {
  system,
  light,
  dark
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final repo = ref.watch(displaySettingsRepositoryProvider);
  return ThemeModeNotifier(repo);
});

final timeFormatProvider = StateNotifierProvider<TimeFormatNotifier, TimeFormat>((ref) {
  final repo = ref.watch(displaySettingsRepositoryProvider);
  return TimeFormatNotifier(repo);
});

class DisplaySettingsRepository {
  final SharedPreferences _prefs;
  static const _keyTimeFormat = 'display_time_format';
  static const _keyThemeMode = 'display_theme_mode';

  DisplaySettingsRepository(this._prefs);

  TimeFormat getTimeFormat() {
    final val = _prefs.getString(_keyTimeFormat);
    if (val == '24h') return TimeFormat.h24;
    return TimeFormat.h12; // Default
  }

  Future<void> setTimeFormat(TimeFormat format) async {
    final val = format == TimeFormat.h24 ? '24h' : '12h';
    await _prefs.setString(_keyTimeFormat, val);
  }

  AppThemeMode getThemeMode() {
    final val = _prefs.getString(_keyThemeMode);
    if (val == 'light') return AppThemeMode.light;
    if (val == 'dark') return AppThemeMode.dark;
    return AppThemeMode.system; // Default
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    String val = 'system';
    if (mode == AppThemeMode.light) val = 'light';
    if (mode == AppThemeMode.dark) val = 'dark';
    await _prefs.setString(_keyThemeMode, val);
  }
}

class TimeFormatNotifier extends StateNotifier<TimeFormat> {
  final DisplaySettingsRepository _repo;

  TimeFormatNotifier(this._repo) : super(_repo.getTimeFormat());

  Future<void> setFormat(TimeFormat format) async {
    await _repo.setTimeFormat(format);
    state = format;
  }
}

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final DisplaySettingsRepository _repo;

  ThemeModeNotifier(this._repo) : super(_repo.getThemeMode());

  Future<void> setMode(AppThemeMode mode) async {
    await _repo.setThemeMode(mode);
    state = mode;
  }
}
