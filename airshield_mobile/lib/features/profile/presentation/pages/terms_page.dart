import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Terms of Service Page
/// 
/// Shows the app's terms of service
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Terms of Service',
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
            'Effective Date',
            'January 29, 2024',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Agreement to Terms',
            'By accessing or using the AirShield mobile application, you agree to be bound by these '
            'Terms of Service. If you do not agree to these terms, please do not use our app.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Description of Service',
            'AirShield provides:\n\n'
            '• Real-time air quality monitoring and alerts\n'
            '• Smart home device control and automation\n'
            '• Historical air quality data and analytics\n'
            '• Health recommendations based on air quality\n'
            '• Integration with third-party smart devices',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'User Accounts',
            'You are responsible for:\n\n'
            '• Maintaining the confidentiality of your account credentials\n'
            '• All activities that occur under your account\n'
            '• Providing accurate and complete information\n'
            '• Updating your information to keep it current\n'
            '• Notifying us immediately of any unauthorized access',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Acceptable Use',
            'You agree NOT to:\n\n'
            '• Use the app for any illegal purposes\n'
            '• Attempt to gain unauthorized access to our systems\n'
            '• Interfere with the proper functioning of the app\n'
            '• Reverse engineer or decompile the software\n'
            '• Use automated systems to access the app\n'
            '• Transmit any malicious code or viruses',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Smart Device Control',
            'When using AirShield to control smart home devices:\n\n'
            '• You are responsible for the proper setup and maintenance of your devices\n'
            '• We are not liable for device malfunctions or damage\n'
            '• Follow manufacturer guidelines for device operation\n'
            '• Ensure your home network is secure\n'
            '• Automation rules are executed at your own risk',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Data Accuracy',
            'While we strive to provide accurate air quality data:\n\n'
            '• Data is provided "as is" without warranties\n'
            '• We rely on third-party data sources\n'
            '• Real-time data may have delays or inaccuracies\n'
            '• Do not rely solely on our app for health decisions\n'
            '• Consult healthcare professionals for medical advice',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Intellectual Property',
            'All content, features, and functionality of AirShield are owned by us and protected by '
            'intellectual property laws. You may not copy, modify, distribute, or create derivative '
            'works without our express written permission.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Limitation of Liability',
            'To the maximum extent permitted by law, AirShield shall not be liable for:\n\n'
            '• Indirect, incidental, or consequential damages\n'
            '• Loss of profits, data, or business opportunities\n'
            '• Damages resulting from device malfunctions\n'
            '• Inaccurate air quality data or health recommendations\n'
            '• Third-party service interruptions',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Subscription and Payments',
            'Some features may require a subscription:\n\n'
            '• Subscription fees are charged in advance\n'
            '• Automatic renewal unless cancelled before renewal date\n'
            '• Refunds are provided according to our refund policy\n'
            '• Prices may change with 30 days notice\n'
            '• Free trial periods may be offered',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Termination',
            'We may suspend or terminate your account if:\n\n'
            '• You violate these Terms of Service\n'
            '• Your account shows fraudulent activity\n'
            '• Required by law or regulatory authorities\n'
            '• We discontinue the service (with notice)',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Changes to Terms',
            'We reserve the right to modify these terms at any time. Material changes will be '
            'notified through the app or via email. Continued use after changes constitutes '
            'acceptance of the new terms.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Governing Law',
            'These terms are governed by the laws of the State of California, USA, without regard '
            'to conflict of law principles.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Contact Information',
            'For questions about these Terms of Service:\n\n'
            'Email: legal@airshield.app\n'
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
