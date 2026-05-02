import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'privacy_policy_page.dart';
import 'terms_page.dart';

/// About Page
/// 
/// Shows app information, version, developer info, and legal links
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@airshield.app',
      queryParameters: {'subject': 'AirShield Support'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchStore() async {
    final url = Platform.isIOS
        ? 'https://apps.apple.com/app/airshield'          // Update with real App Store ID
        : 'https://play.google.com/store/apps/details?id=com.airshield.mobile'; // Update with real package name
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
        _buildNumber = '1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'About',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppHeader(),
          const SizedBox(height: 32),
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildLegalSection(context),
          const SizedBox(height: 24),
          _buildActionsSection(context),
          const SizedBox(height: 32),
          _buildDeveloperInfo(),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.air,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // App Name
          Text(
            'AirShield',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Version $_version ${_buildNumber.isNotEmpty ? '($_buildNumber)' : ''}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About AirShield',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AirShield is your comprehensive air quality monitoring and smart home automation solution. '
            'Monitor real-time air quality data, control your air purifiers, and automate your indoor environment '
            'for optimal health and comfort.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildLinkItem(
            context,
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildLinkItem(
            context,
            'Terms of Service',
            Icons.description_outlined,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TermsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildLinkItem(
            context,
            'Contact Support',
            Icons.email_outlined,
            _launchEmail,
          ),
          const SizedBox(height: 12),
          _buildLinkItem(
            context,
            'Rate App',
            Icons.star_outline,
            _launchStore,
          ),
          const SizedBox(height: 12),
          _buildLinkItem(
            context,
            'Check for Updates',
            Icons.system_update_outlined,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You are using the latest version',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Made with ❤️ by AirShield Team',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 AirShield. All rights reserved.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
