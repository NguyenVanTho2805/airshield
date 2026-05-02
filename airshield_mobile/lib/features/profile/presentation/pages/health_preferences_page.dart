import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/health_condition.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/profile_bloc.dart';

/// Health Preferences Page
/// 
/// Allows users to set their health conditions and AQI preferences
class HealthPreferencesPage extends StatefulWidget {
  const HealthPreferencesPage({super.key});

  @override
  State<HealthPreferencesPage> createState() => _HealthPreferencesPageState();
}

class _HealthPreferencesPageState extends State<HealthPreferencesPage> {
  List<HealthCondition> _selectedConditions = [];
  int _sensitivity = 3;
  int _customThreshold = 100;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadHealthConditions());
  }

  void _savePreferences() {
    context.read<ProfileBloc>().add(
          UpdateHealthConditions(_selectedConditions),
        );
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Health preferences saved successfully',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() {
            _selectedConditions = state.healthConditions;
            _sensitivity = state.user.aqiSensitivityLevel;
            _customThreshold = state.user.customAqiThreshold;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            l10n.healthPreferences,
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
            _buildHealthConditionsSection(),
            const SizedBox(height: 24),
            _buildSensitivitySection(),
            const SizedBox(height: 24),
            _buildCustomThresholdSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthConditionsSection() {
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
          Row(
            children: [
              const Icon(Icons.medical_services, color: Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              Text(
                'Health Conditions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...HealthConditionType.values
              .where((type) => type != HealthConditionType.none)
              .map((type) => _buildConditionTile(type)),
        ],
      ),
    );
  }

  Widget _buildConditionTile(HealthConditionType type) {
    final isSelected = _selectedConditions.any((c) => c.type == type);
    
    return CheckboxListTile(
      title: Row(
        children: [
          Text(
            type.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            type.displayName,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
      value: isSelected,
      activeColor: const Color(0xFF4CAF50),
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedConditions.add(
              HealthCondition(type: type),
            );
          } else {
            _selectedConditions.removeWhere((c) => c.type == type);
          }
        });
      },
    );
  }

  Widget _buildSensitivitySection() {
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
            'AQI Sensitivity Level',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How sensitive are you to air quality?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                'High',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          Slider(
            value: _sensitivity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: const Color(0xFF4CAF50),
            label: _sensitivity.toString(),
            onChanged: (value) {
              setState(() {
                _sensitivity = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomThresholdSection() {
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
            'Custom Alert Threshold',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get notified when AQI exceeds: $_customThreshold',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _customThreshold.toDouble(),
            min: 50,
            max: 200,
            divisions: 15,
            activeColor: const Color(0xFF4CAF50),
            label: _customThreshold.toString(),
            onChanged: (value) {
              setState(() {
                _customThreshold = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePreferences,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Preferences',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
