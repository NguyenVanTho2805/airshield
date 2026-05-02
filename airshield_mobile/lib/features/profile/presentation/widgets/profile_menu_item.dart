import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Profile Menu Item Widget
/// 
/// Reusable menu item for profile page
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showTrailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF4CAF50)).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              )
            : null,
        trailing: showTrailing
            ? const Icon(
                Icons.chevron_right,
                color: Colors.white38,
              )
            : null,
      ),
    );
  }
}
