import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/custom_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Les settings sont déjà chargés via le provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppearanceSection(),
            _buildNotificationSection(),
            _buildLanguageSection(),
            _buildAboutSection(),
            _buildDataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppStyles.paddingL),
          padding: const EdgeInsets.all(AppStyles.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingM),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: AppStyles.iconM,
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingM),
                  Text(
                    'Apparence',
                    style: AppStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.paddingL),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Mode sombre',
                    style: AppStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Activer le thème sombre pour une meilleure expérience nocturne',
                    style: AppStyles.bodySmall(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(AppStyles.paddingS),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusS),
                    ),
                    child: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: themeProvider.isDarkMode 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSection() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final settings = notificationProvider.settings;
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppStyles.paddingL),
          padding: const EdgeInsets.all(AppStyles.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingM),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: AppStyles.iconM,
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingM),
                  Text(
                    'Notifications',
                    style: AppStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.paddingL),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Notifications activées',
                    style: AppStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    settings.isEnabled
                        ? 'Recevoir des rappels d\'expiration'
                        : 'Notifications désactivées',
                    style: AppStyles.bodySmall(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: settings.isEnabled,
                  onChanged: (value) {
                    notificationProvider.updateSettings(
                      settings.copyWith(isEnabled: value),
                    );
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(AppStyles.paddingS),
                    decoration: BoxDecoration(
                      color: settings.isEnabled
                          ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusS),
                    ),
                    child: Icon(
                      settings.isEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: settings.isEnabled
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
              if (settings.isEnabled) ...[
                const SizedBox(height: AppStyles.paddingM),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Rappel avant expiration',
                          style: AppStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${settings.reminderDays.join(', ')} jour${settings.reminderDays.length > 1 ? 's' : ''} avant',
                          style: AppStyles.bodySmall(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(AppStyles.paddingS),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppStyles.radiusS),
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showReminderDaysDialog(notificationProvider),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Heure des rappels',
                          style: AppStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          settings.formattedTime,
                          style: AppStyles.bodySmall(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(AppStyles.paddingS),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppStyles.radiusS),
                          ),
                          child: Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showTimePickerDialog(notificationProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.paddingM),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Son',
                          style: AppStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Jouer un son pour les notifications',
                          style: AppStyles.bodySmall(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: settings.soundEnabled,
                        onChanged: (value) {
                          notificationProvider.updateSettings(
                            settings.copyWith(soundEnabled: value),
                          );
                        },
                        secondary: Container(
                          padding: const EdgeInsets.all(AppStyles.paddingS),
                          decoration: BoxDecoration(
                            color: settings.soundEnabled
                                ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppStyles.radiusS),
                          ),
                          child: Icon(
                            settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
                            color: settings.soundEnabled
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: Text(
                          'Vibration',
                          style: AppStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Vibrer lors des notifications',
                          style: AppStyles.bodySmall(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: settings.vibrationEnabled,
                        onChanged: (value) {
                          notificationProvider.updateSettings(
                            settings.copyWith(vibrationEnabled: value),
                          );
                        },
                        secondary: Container(
                          padding: const EdgeInsets.all(AppStyles.paddingS),
                          decoration: BoxDecoration(
                            color: settings.vibrationEnabled
                                ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppStyles.radiusS),
                          ),
                          child: Icon(
                            settings.vibrationEnabled ? Icons.vibration : Icons.phone_android,
                            color: settings.vibrationEnabled
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.paddingM),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: ListTile(
                    title: Text(
                      'Tester les notifications',
                      style: AppStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Envoyer une notification de test',
                      style: AppStyles.bodySmall(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(AppStyles.paddingS),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppStyles.radiusS),
                      ),
                      child: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implémenter la fonction de test de notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonction de test à implémenter'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showReminderDaysDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rappel avant expiration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nombre de jours avant l\'expiration :'),
            const SizedBox(height: 16),
            ...List.generate(7, (index) {
              final days = index + 1;
              return CheckboxListTile(
                title: Text('$days jour${days > 1 ? 's' : ''}'),
                value: provider.settings.reminderDays.contains(days),
                onChanged: (checked) {
                  if (checked != null) {
                    final currentDays = List<int>.from(provider.settings.reminderDays);
                    if (checked) {
                      currentDays.add(days);
                    } else {
                      currentDays.remove(days);
                    }
                    provider.updateSettings(
                      provider.settings.copyWith(reminderDays: currentDays),
                    );
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog(NotificationProvider provider) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: provider.settings.reminderHour,
        minute: provider.settings.reminderMinute,
      ),
    ).then((time) {
      if (time != null) {
        provider.updateSettings(
          provider.settings.copyWith(
            reminderHour: time.hour,
            reminderMinute: time.minute,
          ),
        );
      }
    });
  }

  Widget _buildLanguageSection() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppStyles.paddingL),
          padding: const EdgeInsets.all(AppStyles.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingM),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Icon(
                      Icons.language,
                      color: AppColors.onPrimary,
                      size: AppStyles.iconM,
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingM),
                  Text(
                    'Langue',
                    style: AppStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.paddingL),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Français'),
                      subtitle: const Text('French'),
                      value: 'fr',
                      groupValue: localeProvider.currentLanguage,
                      onChanged: (value) {
                        if (value != null) {
                          localeProvider.setLocale(Locale(value));
                        }
                      },
                      secondary: const Text(
                        '🇫🇷',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    RadioListTile<String>(
                      title: const Text('English'),
                      subtitle: const Text('Anglais'),
                      value: 'en',
                      groupValue: localeProvider.currentLanguage,
                      onChanged: (value) {
                        if (value != null) {
                          localeProvider.setLocale(Locale(value));
                        }
                      },
                      secondary: const Text(
                        '🇺🇸',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingL),
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(
                  Icons.info,
                  color: AppColors.onPrimary,
                  size: AppStyles.iconM,
                ),
              ),
              const SizedBox(width: AppStyles.paddingM),
              Text(
                'À propos',
                style: AppStyles.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingL),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Version de l\'application'),
                  subtitle: const Text('1.0.0'),
                  leading: Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Développé par'),
                  subtitle: const Text('MingiYaqu Team'),
                  leading: Icon(
                    Icons.code,
                    color: AppColors.primary,
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Licence'),
                  subtitle: const Text('MIT License'),
                  leading: Icon(
                    Icons.description,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLicenseDialog(),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Signaler un problème'),
                  subtitle: const Text('Nous aider à améliorer l\'application'),
                  leading: Icon(
                    Icons.bug_report,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFeedbackDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingL),
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(
                  Icons.storage,
                  color: AppColors.onPrimary,
                  size: AppStyles.iconM,
                ),
              ),
              const SizedBox(width: AppStyles.paddingM),
              Text(
                'Données',
                style: AppStyles.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingL),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Exporter les données'),
                  subtitle: const Text('Sauvegarder vos produits'),
                  leading: Icon(
                    Icons.download,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showExportDialog(),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Importer les données'),
                  subtitle: const Text('Restaurer une sauvegarde'),
                  leading: Icon(
                    Icons.upload,
                    color: AppColors.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showImportDialog(),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Effacer toutes les données'),
                  subtitle: const Text('Supprimer tous les produits'),
                  leading: Icon(
                    Icons.delete_forever,
                    color: AppColors.error,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearDataDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Licence MIT'),
        content: const SingleChildScrollView(
          child: Text(
            'MIT License\n\n'
            'Copyright (c) 2024 MingiYaqu\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy '
            'of this software and associated documentation files (the "Software"), to deal '
            'in the Software without restriction, including without limitation the rights '
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
            'copies of the Software, and to permit persons to whom the Software is '
            'furnished to do so, subject to the following conditions:\n\n'
            'The above copyright notice and this permission notice shall be included in all '
            'copies or substantial portions of the Software.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: const Text(
          'Pour signaler un problème ou suggérer une amélioration, '
          'contactez-nous à l\'adresse : support@mingiyaqu.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: const Text(
          'Cette fonctionnalité permettra d\'exporter vos données '
          'vers un fichier de sauvegarde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          PrimaryButton(
            text: 'Exporter',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à implémenter'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer les données'),
        content: const Text(
          'Cette fonctionnalité permettra d\'importer des données '
          'depuis un fichier de sauvegarde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          PrimaryButton(
            text: 'Importer',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à implémenter'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer toutes les données'),
        content: const Text(
          'Cette action supprimera définitivement tous vos produits. '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fonctionnalité à implémenter'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppStyles.paddingM),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.paddingL),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppStyles.iconM,
                ),
                const SizedBox(width: AppStyles.paddingM),
                Text(
                    title,
                    style: AppStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}