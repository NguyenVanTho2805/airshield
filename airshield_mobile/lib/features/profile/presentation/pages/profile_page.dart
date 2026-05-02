import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/data/models/user.dart';
import '../widgets/profile_menu_item.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/locations_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import 'edit_profile_page.dart';
import 'health_preferences_page.dart';
import 'saved_locations_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'privacy_policy_page.dart';
import '../../../automation/presentation/pages/automation_rules_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

/// Profile Page
/// 
/// User profile with settings and logout
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            );
          }

          return _buildContent(context, state.user);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserHeader(user),
          const SizedBox(height: 32),
          _buildAccountStats(user),
          const SizedBox(height: 32),
          _buildMenuSection(context),
          const SizedBox(height: 24),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(user.name),
                    ),
                  )
                : _buildDefaultAvatar(user.name),
          ),
          const SizedBox(width: 20),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Premium Member',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAccountStats(User user) {
    final memberSince = user.createdAt != null
        ? DateFormat('MMM yyyy').format(user.createdAt!)
        : 'Jan 2024';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Member Since',
            memberSince,
            Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Devices',
            '2',
            Icons.devices_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) return const SizedBox();
            
            return Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your information',
                  onTap: () {
                    // Provide ProfileBloc when navigating
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => ProfileBloc(
                            repository: ProfileRepository(),
                          )..add(LoadProfile(authState.user)),
                          child: EditProfilePage(user: authState.user),
                        ),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Health Preferences',
                  subtitle: 'Manage health conditions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => ProfileBloc(
                            repository: ProfileRepository(),
                          )..add(LoadProfile(authState.user)),
                          child: const HealthPreferencesPage(),
                        ),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.place_outlined,
                  title: 'Saved Locations',
                  subtitle: 'Manage your locations',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => LocationsBloc(
                            repository: ProfileRepository(),
                          )..add(LoadLocations()),
                          child: const SavedLocationsPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'General',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ProfileMenuItem(
          icon: Icons.auto_awesome_outlined,
          title: 'Automation Rules',
          subtitle: 'Manage automation',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AutomationRulesPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'View all notifications',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Notifications, theme, language',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App information',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'View privacy policy',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Support page coming soon!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: const Color(0xFF16213E),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF44336),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF44336),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Row(
          children: [
            const Icon(Icons.air, color: Color(0xFF4CAF50), size: 32),
            const SizedBox(width: 12),
            Text(
              'AirShield',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Air Quality Monitoring & Smart Home Control',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 AirShield. All rights reserved.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: const Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}
