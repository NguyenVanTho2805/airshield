import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cached text styles — evaluated once, reused across every rebuild.
///
/// Use these instead of calling GoogleFonts.poppins() inside build() methods.
/// Each static final is lazily initialised on first access and kept alive
/// for the lifetime of the app, eliminating per-frame TextStyle allocations.
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ──────────────────────────────────────────────────────────────
  static final TextStyle appTitle = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
  );
  static final TextStyle pageTitle = GoogleFonts.poppins(
    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
  );
  static final TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static final TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
  );

  // ── AQI-specific ──────────────────────────────────────────────────────────
  static final TextStyle aqiValue = GoogleFonts.poppins(
    fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white,
  );
  static final TextStyle aqiLabel = GoogleFonts.poppins(
    fontSize: 16, color: Colors.white70,
  );
  static final TextStyle aqiBadge = GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
  );

  // ── Pollutant cards ───────────────────────────────────────────────────────
  static final TextStyle pollutantValue = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
  );
  static final TextStyle pollutantName = GoogleFonts.poppins(
    fontSize: 14, color: Colors.white70,
  );
  static final TextStyle pollutantUnit = GoogleFonts.poppins(
    fontSize: 12, color: Colors.white54,
  );

  // ── Body ──────────────────────────────────────────────────────────────────
  static final TextStyle bodyWhite = GoogleFonts.poppins(
    fontSize: 16, color: Colors.white,
  );
  static final TextStyle bodySecondary = GoogleFonts.poppins(
    fontSize: 16, color: Colors.white70,
  );
  static final TextStyle labelWhite = GoogleFonts.poppins(
    fontSize: 14, color: Colors.white,
  );
  static final TextStyle labelSecondary = GoogleFonts.poppins(
    fontSize: 14, color: Colors.white70,
  );
  static final TextStyle labelStrong = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 12, color: Colors.white54,
  );
  static final TextStyle captionSecondary = GoogleFonts.poppins(
    fontSize: 12, color: Colors.white70,
  );
  static final TextStyle tiny = GoogleFonts.poppins(
    fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w600,
  );
  static final TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600,
  );
  static final TextStyle linkGreen = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50),
  );
  static final TextStyle linkMuted = GoogleFonts.poppins(
    fontSize: 14, color: Colors.white54,
  );

  // ── Navigation bar ────────────────────────────────────────────────────────
  static final TextStyle navLabel = GoogleFonts.poppins(fontSize: 12);
}
