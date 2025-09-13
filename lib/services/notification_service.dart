import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/notification_settings.dart';
import '../models/product.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Configuration Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuration iOS
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

      _initialized = true;
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tappée: ${response.payload}');
    // Ici, vous pouvez naviguer vers une page spécifique
  }

  Future<bool> checkPermissions() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Erreur lors de la demande de permissions: $e');
      return false;
    }
  }

  Future<void> scheduleNotifications(NotificationSettings settings) async {
    if (!_initialized || !settings.isEnabled) return;

    try {
      // Annuler toutes les notifications existantes
      await cancelAllNotifications();

      // Programmer les nouvelles notifications
      // Note: Dans une vraie implémentation, vous devriez programmer
      // les notifications pour chaque produit individuellement
      
    } catch (e) {
      debugPrint('Erreur lors de la programmation des notifications: $e');
    }
  }

  Future<void> scheduleProductNotification({
    required Product product,
    required NotificationSettings settings,
    required int daysBeforeExpiration,
  }) async {
    if (!_initialized || !settings.isEnabled) return;

    try {
      final notificationDate = product.expirationDate.subtract(
        Duration(days: daysBeforeExpiration),
      );

      // Ne programmer que si la date est dans le futur
      if (notificationDate.isBefore(DateTime.now())) return;

      final scheduledDate = DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        settings.reminderHour,
        settings.reminderMinute,
      );

      final notificationId = _generateNotificationId(product.id, daysBeforeExpiration);
      
      String title;
      String body;
      
      if (daysBeforeExpiration == 0) {
        title = 'Produit expiré!';
        body = '${product.name} a expiré aujourd\'hui';
      } else if (daysBeforeExpiration == 1) {
        title = 'Expiration demain!';
        body = '${product.name} expire demain';
      } else {
        title = 'Expiration proche!';
        body = '${product.name} expire dans $daysBeforeExpiration jours';
      }

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        _convertToTZDateTime(scheduledDate),
        _getNotificationDetails(settings),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: product.id,
      );
    } catch (e) {
      debugPrint('Erreur lors de la programmation de la notification pour ${product.name}: $e');
    }
  }

  Future<void> cancelProductNotifications(String productId) async {
    if (!_initialized) return;

    try {
      // Annuler toutes les notifications pour ce produit
      for (int days in [0, 1, 3, 7]) {
        final notificationId = _generateNotificationId(productId, days);
        await _notifications.cancel(notificationId);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'annulation des notifications pour le produit $productId: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;

    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Erreur lors de l\'annulation de toutes les notifications: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_initialized) return;

    try {
      await _notifications.show(
        999999, // ID unique pour le test
        'Test de notification',
        'Ceci est une notification de test pour MingiYaqu',
        _getNotificationDetails(NotificationSettings()),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'affichage de la notification de test: $e');
    }
  }

  NotificationDetails _getNotificationDetails(NotificationSettings settings) {
    final androidDetails = AndroidNotificationDetails(
      'mingi_yaqu_channel',
      'Rappels d\'expiration',
      channelDescription: 'Notifications pour les produits qui expirent bientôt',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: settings.vibrationEnabled,
      playSound: settings.soundEnabled,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  int _generateNotificationId(String productId, int daysBeforeExpiration) {
    // Générer un ID unique basé sur l'ID du produit et les jours avant expiration
    return '${productId}_$daysBeforeExpiration'.hashCode;
  }

  // Note: Cette méthode nécessite le package timezone
  // Pour simplifier, nous utilisons DateTime directement
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // Dans une vraie implémentation, vous devriez utiliser:
    // return tz.TZDateTime.from(dateTime, tz.local);
    return dateTime;
  }
}