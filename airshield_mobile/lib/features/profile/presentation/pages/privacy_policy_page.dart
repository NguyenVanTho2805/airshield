import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Privacy Policy Page
/// 
/// Shows the app's privacy policy
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Privacy Policy',
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
          _buildSection(
            context,
            'Last Updated',
            'January 29, 2024',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Introduction',
            'AirShield ("we", "our", or "us") is committed to protecting your privacy. '
            'This Privacy Policy explains how we collect, use, disclose, and safeguard your '
            'information when you use our mobile application.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Information We Collect',
            'We collect information that you provide directly to us, including:\n\n'
            '• Account Information: Name, email address, and password\n'
            '• Location Data: To provide air quality information for your area\n'
            '• Device Information: Smart home device data and preferences\n'
            '• Usage Data: How you interact with our app and services',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'How We Use Your Information',
            'We use the collected information to:\n\n'
            '• Provide and maintain our services\n'
            '• Display real-time air quality data for your location\n'
            '• Control and monitor your smart home devices\n'
            '• Send you important notifications and updates\n'
            '• Improve our app and user experience\n'
            '• Analyze usage patterns and trends',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Data Security',
            'We implement appropriate technical and organizational security measures to protect '
            'your personal information. However, no method of transmission over the internet or '
            'electronic storage is 100% secure, and we cannot guarantee absolute security.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Data Sharing',
            'We do not sell your personal information to third parties. We may share your information with:\n\n'
            '• Service providers who assist us in operating our app\n'
            '• Smart home device manufacturers for device control\n'
            '• Air quality data providers for accurate information\n'
            '• Legal authorities when required by law',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Your Rights',
            'You have the right to:\n\n'
            '• Access your personal information\n'
            '• Correct inaccurate data\n'
            '• Delete your account and data\n'
            '• Opt-out of marketing communications\n'
            '• Export your data in a portable format',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Children\'s Privacy',
            'Our service is not intended for children under 13 years of age. We do not knowingly '
            'collect personal information from children under 13.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Changes to This Policy',
            'We may update this Privacy Policy from time to time. We will notify you of any changes '
            'by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Contact Us',
            'If you have questions about this Privacy Policy, please contact us at:\n\n'
            'Email: privacy@airshield.app\n'
            'Address: AirShield, Inc., 123 Air Quality St., San Francisco, CA 94102',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
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
}
