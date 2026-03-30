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
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Added
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Added
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization aggressively mounts Firestore offline sockets Native Android.
  // Explicitly removed so purely SharedPreferences array strings execute preventing Foreground send Deadlocks seamlessly.
  if (message.notification == null) {
    await _showLocalNotification(message);
  }
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  print("--- BACKGROUND NOTIFICATION WAKE ---");
  print("Platform: $defaultTargetPlatform");
  if (defaultTargetPlatform != TargetPlatform.android) return;

  final data = message.data;
  print("Data Payload: $data");

  final type = data['type'] ?? 'system';
  if (type != 'new_message' && type != 'new_comment' && type != 'new_reaction') {
    print("Unhandled data message type: $type. Returning.");
    return;
  }

  String threadId = 'general';
  String title = data['title'] ?? 'New Notification';
  String body = data['body'] ?? '';
  String summarySuffix = 'new notifications';

  if (type == 'new_message') {
    threadId = data['chatId'] ?? 'general';
    final senderName = data['senderName'] ?? title;
    body = "$senderName: $body";
    summarySuffix = 'new messages';
  } else if (type == 'new_comment') {
    threadId = data['postId'] ?? data['docId'] ?? 'comments';
    summarySuffix = 'new comments';
  } else if (type == 'new_reaction') {
    threadId = data['commentId'] ?? data['docId'] ?? 'reactions';
    summarySuffix = 'new reactions';
  }

  print("Loading SharedPreferences...");
  final prefs = await SharedPreferences.getInstance();
  final historyKey = 'notification_history_$threadId';

  List<String> history = prefs.getStringList(historyKey) ?? [];
  history.add(body);

  if (history.length > 7) {
    history.removeRange(0, history.length - 7);
  }
  await prefs.setStringList(historyKey, history);
  print("Saved History: $history");

  final inboxStyle = InboxStyleInformation(
    history,
    contentTitle: title,
    summaryText: "${history.length} $summarySuffix",
  );

  print("Initializing Local Notifications...");
  final flnp = FlutterLocalNotificationsPlugin();
  await flnp.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  print("Triggering flnp.show() for thread: $threadId...");
  try {
    await flnp.show(
      id: threadId.hashCode, // One unique expanding card per Thread natively
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          styleInformation: inboxStyle,
          priority: Priority.high,
          importance: Importance.max,
          groupKey: threadId,
          onlyAlertOnce: true, // Silently updates the card without redundant ring constraints!
        ),
      ),
      payload: jsonEncode(data),
    );
    print("SUCCESS: Notification Drawn Locally!");
  } catch (e) {
    print("FATAL ERROR IN BACKGROUND ISOLATE: $e");
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);

void Function(Map<String, dynamic>)? onNotificationTap;

void handleNotificationDeepLink(Map<String, dynamic> data) {
  if (onNotificationTap != null) {
    onNotificationTap!(data);
  } else {
    SharedPreferences.getInstance().then((prefs) {
      if (data['type'] == 'b2b_alert' || data['targetVenueId'] != null) {
        final venueId = data['targetVenueId'] ?? data['venueId'];
        if (venueId != null) prefs.setString('pending_b2b_context', venueId);
      }
    });
  }
}

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
    settings: const InitializationSettings(
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
      int notificationId = notification.hashCode; // Unique constraint per message payload
      String? threadId;

      if (message.data['type'] == 'new_message' && message.data['chatId'] != null) {
        threadId = message.data['chatId'];
        notificationId = threadId.hashCode;
      }

      flutterLocalNotificationsPlugin.show(
        id: notificationId,
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
            groupKey: threadId,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: threadId,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } else if (notification == null && message.data.isNotEmpty) {
      // Offline/Data-only Foreground Pass-through tracking InboxStyle arrays perfectly
      _showLocalNotification(message);
    }
  });

  // Force Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        // Map the legacy role to the new architecture if systemRole isn't set yet
        'systemRole': data['systemRole'] ?? data['role'] ?? 'user',
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
    onNotificationTap = _handleNotificationDeepLink;
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

    // Handle Firebase Push Notification Deep Links inside ProviderScope
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _handleNotificationDeepLink(initialMessage.data);
      });
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationDeepLink(message.data);
    });
  }

  void _handleNotificationDeepLink(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if the notification is a B2B alert that demands a context switch
    if (data['type'] == 'b2b_alert' || data['targetVenueId'] != null) {
      final venueId = data['targetVenueId'] ?? data['venueId'];
      if (venueId != null) {
        await prefs.setString('pending_b2b_context', venueId);
        ref.invalidate(pendingInviteProvider);
      }
    }

    // Default chat routing
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

    // Deferred Feed Deep-Link Routing
    final type = uri.queryParameters['type'];
    final docId = uri.queryParameters['id'];
    if (uri.toString().contains('feed') && type != null && docId != null) {
      print("Deep Link Detected: Deferred Feed Routing -> type:$type id:$docId");
      await prefs.setString('pending_feed_type', type);
      await prefs.setString('pending_feed_id', docId);
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
