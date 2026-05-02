import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/l10n/language_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Settings Page
/// 
/// App settings and preferences
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _aqiAlertsEnabled = true;
  bool _deviceAlertsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.settings,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(l10n.translate('notifications')),
          _buildSwitchTile(
            l10n.translate('enable_notifications'),
            l10n.translate('receive_alerts_updates'),
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSwitchTile(
            l10n.translate('aqi_alerts'),
            l10n.translate('notify_aqi_changes'),
            _aqiAlertsEnabled,
            (value) => setState(() => _aqiAlertsEnabled = value),
          ),
          _buildSwitchTile(
            l10n.translate('device_alerts'),
            l10n.translate('notify_devices_attention'),
            _deviceAlertsEnabled,
            (value) => setState(() => _deviceAlertsEnabled = value),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.translate('appearance')),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return _buildOptionTile(
                l10n.theme,
                _getThemeName(state.themeMode, l10n),
                Icons.palette_outlined,
                () => _showThemeDialog(context, l10n),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.translate('general')),
          BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, state) {
              return _buildOptionTile(
                l10n.language,
                state.locale.languageCode == 'vi' ? l10n.vietnamese : l10n.english,
                Icons.language_outlined,
                () => _showLanguageDialog(context, l10n),
              );
            },
          ),
          _buildOptionTile(
            l10n.translate('app_version'),
            '1.0.0',
            Icons.info_outline,
            null,
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.state.themeMode;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          l10n.selectTheme,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              dialogContext,
              l10n.dark,
              Icons.dark_mode,
              ThemeMode.dark,
              currentTheme == ThemeMode.dark,
              () {
                themeBloc.add(const ChangeTheme(ThemeMode.dark));
                Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              dialogContext,
              l10n.light,
              Icons.light_mode,
              ThemeMode.light,
              currentTheme == ThemeMode.light,
              () {
                themeBloc.add(const ChangeTheme(ThemeMode.light));
                Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              dialogContext,
              l10n.system,
              Icons.settings_suggest,
              ThemeMode.system,
              currentTheme == ThemeMode.system,
              () {
                themeBloc.add(const ChangeTheme(ThemeMode.system));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    final languageBloc = context.read<LanguageBloc>();
    final currentLocale = languageBloc.state.locale;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          l10n.selectLanguage,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              dialogContext,
              l10n.english,
              '🇺🇸',
              const Locale('en'),
              currentLocale.languageCode == 'en',
              () {
                languageBloc.add(const ChangeLanguage(Locale('en')));
                Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              dialogContext,
              l10n.vietnamese,
              '🇻🇳',
              const Locale('vi'),
              currentLocale.languageCode == 'vi',
              () {
                languageBloc.add(const ChangeLanguage(Locale('vi')));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF4CAF50)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF4CAF50)
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String flag,
    Locale locale,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF4CAF50)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    String value,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.38),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
