import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard Error Widget
/// 
/// Displays error message with retry button when data fetch fails
class DashboardErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DashboardErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Color(0xFFF44336),
              ),
            ),
            const SizedBox(height: 24),
            
            // Error title
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Error message
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Retry button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
