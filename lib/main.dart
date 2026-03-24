import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'features/settings/data/display_settings_repository.dart';
import 'features/messaging/presentation/chat_screen.dart';

import 'dart:async'; // Added
import 'dart:convert'; // Added
import 'package:app_links/app_links.dart'; // Added
import 'package:firebase_messaging/firebase_messaging.dart'; // Added
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Added
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleNotificationDeepLink(Map<String, dynamic> data) {
  if (data['type'] == 'new_message' && data['chatId'] != null) {
    final chatName = data['chatName'] ?? 'Chat';
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(chatId: data['chatId'], chatName: chatName),
      ),
    );
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        try {
          final data = Map<String, dynamic>.from(jsonDecode(response.payload!));
          handleNotificationDeepLink(data);
        } catch (_) {}
      }
    },
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            priority: Priority.high,
            importance: Importance.max,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  });

  // Force Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Handle Terminated Deep Links
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      handleNotificationDeepLink(initialMessage.data);
    });
  }

  // Handle Background Deep Links
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationDeepLink(message.data);
  });

  final prefs = await SharedPreferences.getInstance();

  // Temporary Migration Script for Main Account
  try {
    print("Running Temp Account Migration...");
    final auth = FirebaseAuth.instance;
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // wait for auth state
    final user = auth.currentUser;
    if (user != null) {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection("users").doc(user.uid).get();
      final data = doc.data() ?? {};

      final currentUsername = data['username'] ?? 'admin';

      await db.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? data['email'] ?? '',
        'username': currentUsername,
        'firstName': data['firstName'] ?? 'Admin',
        'lastName': data['lastName'] ?? '',
        'currentPoints': data['currentPoints'] ?? 0,
        'role': data['role'] ?? 'superadmin',
      }, SetOptions(merge: true));

      await db.collection("public_profiles").doc(user.uid).set({
        'uid': user.uid,
        'username': currentUsername,
        'firstName': data['firstName'] ?? 'Admin',
        'lastName': data['lastName'] ?? '',
        'points': data['currentPoints'] ?? 0,
        'realNameVisibility': data['realNameVisibility'] ?? 'Everyone',
        'onlineStatus': 'Online',
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Migration complete for ${user.uid}");
    } else {
      print("No user logged in for migration.");
    }
  } catch (e) {
    print("Error during migration: $e");
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
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
      navigatorKey: navigatorKey,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

// Simple provider to signal AuthWrapper to re-check
final pendingInviteProvider = StateProvider<int>((ref) => 0);
