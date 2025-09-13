import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 1)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool isEnabled;

  @HiveField(1)
  List<int> reminderDays; // Jours avant expiration pour les rappels

  @HiveField(2)
  int reminderHour; // Heure de la journée pour les notifications (0-23)

  @HiveField(3)
  int reminderMinute; // Minute de l'heure pour les notifications (0-59)

  @HiveField(4)
  bool soundEnabled;

  @HiveField(5)
  bool vibrationEnabled;

  NotificationSettings({
    this.isEnabled = true,
    this.reminderDays = const [1, 3, 7], // Par défaut: 1, 3 et 7 jours avant
    this.reminderHour = 9, // 9h du matin par défaut
    this.reminderMinute = 0,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  // Créer une copie avec des modifications
  NotificationSettings copyWith({
    bool? isEnabled,
    List<int>? reminderDays,
    int? reminderHour,
    int? reminderMinute,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  // Obtenir l'heure formatée
  String get formattedTime {
    final hour = reminderHour.toString().padLeft(2, '0');
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  String toString() {
    return 'NotificationSettings{isEnabled: $isEnabled, reminderDays: $reminderDays, time: $formattedTime}';
  }
}