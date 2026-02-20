import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'features/settings/data/display_settings_repository.dart';

import 'dart:async'; // Added
import 'package:app_links/app_links.dart'; // Added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Force Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link (e.g. app launched from link)
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      _handleLink(appLink);
    }

    // Listen to link stream (e.g. app assumes foreground from link)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) async {
    // Shared Preferences logic
    final prefs = await SharedPreferences.getInstance();

    final hallId = uri.queryParameters['hallId'];
    if (hallId != null) {
      print("Deep Link Detected: Joining Hall $hallId");
      await prefs.setString('pending_join_hall', hallId);
      ref.invalidate(pendingInviteProvider);
      return;
    }

    final uid = uri.queryParameters['uid'];
    if (uri.toString().contains('add_friend') && uid != null) {
      print("Deep Link Detected: Add Friend $uid");
      await prefs.setString('pending_add_friend', uid);
      ref.invalidate(pendingInviteProvider);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    ThemeMode themeMode = ThemeMode.system;
    if (mode == AppThemeMode.light) themeMode = ThemeMode.light;
    if (mode == AppThemeMode.dark) themeMode = ThemeMode.dark;

    return MaterialApp(
      title: 'FreeSPC',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

// Simple provider to signal AuthWrapper to re-check
final pendingInviteProvider = StateProvider<int>((ref) => 0);
