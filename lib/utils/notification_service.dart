import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quotes.dart';

/// Notification Service for OSINT Stalker
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notification permission is granted
  Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Show a simple notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'osint_stalker_channel',
      'OSINT Stalker',
      channelDescription: 'Notifikasi dari OSINT Stalker',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF00FF94),
      enableLights: true,
      ledColor: Color(0xFF00FF94),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show welcome notification
  Future<void> showWelcomeNotification() async {
    await showNotification(
      id: 1,
      title: '🔍 OSINT Stalker Ready!',
      body: 'Selamat datang! Aplikasi siap digunakan untuk investigasi digital.',
      payload: 'welcome',
    );
  }

  /// Show security reminder notification
  Future<void> showSecurityReminder() async {
    await showNotification(
      id: 2,
      title: '🔒 Pengingat Keamanan',
      body: 'Aktifkan App Lock untuk mengamankan data investigasi Anda.',
      payload: 'security',
    );
  }

  /// Show update available notification
  Future<void> showUpdateNotification(String version) async {
    await showNotification(
      id: 3,
      title: '🚀 Update Tersedia!',
      body: 'Versi $version sudah tersedia. Update sekarang untuk fitur terbaru.',
      payload: 'update',
    );
  }

  /// Show search completed notification
  Future<void> showSearchCompleted(String target, int resultsCount) async {
    await showNotification(
      id: 4,
      title: '✅ Pencarian Selesai',
      body: 'Ditemukan $resultsCount hasil untuk "$target"',
      payload: 'search_complete',
    );
  }

  /// Show tips notification
  Future<void> showTipsNotification() async {
    final tips = [
      'Gunakan Advanced Dorks untuk hasil lebih akurat!',
      'Coba berbagai Search Engine untuk hasil komprehensif.',
      'Simpan target penting dengan bookmark.',
      'Gunakan custom domain untuk pencarian spesifik.',
      'Aktifkan biometric lock untuk keamanan maksimal.',
    ];
    
    // Mix OSINT tips with security quotes
    final useQuote = DateTime.now().millisecond % 2 == 0;
    
    String title;
    String body;
    
    if (useQuote) {
      final quote = OsintQuotes.getRandomQuote();
      title = '🔒 Security Wisdom';
      body = '${quote.quote}\n— ${quote.author}';
    } else {
      final randomTip = tips[DateTime.now().millisecond % tips.length];
      title = '💡 Tips OSINT';
      body = randomTip;
    }
    
    await showNotification(
      id: 5,
      title: title,
      body: body,
      payload: 'tips',
    );
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // Save schedule preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', true);
    await prefs.setInt('reminder_hour', hour);
    await prefs.setInt('reminder_minute', minute);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}

/// Notification Settings Manager
class NotificationSettingsManager {
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  static Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('daily_reminder_enabled') ?? false;
  }

  static Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', enabled);
  }

  static Future<bool> isSecurityReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('security_reminder_shown') ?? false;
  }

  static Future<void> setSecurityReminderShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_reminder_shown', shown);
  }
}
