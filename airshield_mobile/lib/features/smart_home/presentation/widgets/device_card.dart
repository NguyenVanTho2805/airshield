import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/device.dart';
import '../pages/device_details_page.dart';

/// Device Card Widget
/// 
/// Displays a single smart device with power toggle and mode selection
class DeviceCard extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onPowerToggle;
  final ValueChanged<DeviceMode> onModeChange;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onPowerToggle,
    required this.onModeChange,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DeviceDetailsPage(device: device),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: device.isPowerOn 
                ? const Color(0xFF4CAF50).withValues(alpha: 0.5) 
                : Colors.white12,
            width: device.isPowerOn ? 2 : 1,
          ),
          boxShadow: device.isPowerOn
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildModeSelector(),
            const SizedBox(height: 20),
            _buildFilterBar(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Provider Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getProviderColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.air,
            color: _getProviderColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        // Device Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.deviceName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                device.providerDisplayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        // Power Switch
        Transform.scale(
          scale: 1.2,
          child: Switch(
            value: device.isPowerOn,
            onChanged: (_) => onPowerToggle(),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF4CAF50);
              }
              return Colors.white54;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF4CAF50).withValues(alpha: 0.3);
              }
              return Colors.white24;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    if (!device.isPowerOn) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Power on to select mode',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white38,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Row(
      children: DeviceMode.values.map((mode) {
        final isSelected = device.mode == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => onModeChange(mode),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF4CAF50)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    mode.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.getDisplayName(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterBar() {
    final colorHex = device.filterStatusColor.replaceAll('#', '');
    final filterColor = Color(int.parse('FF$colorHex', radix: 16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filter Life',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            Row(
              children: [
                Text(
                  '${device.filterLife}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: filterColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: filterColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    device.filterStatus,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: filterColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: device.filterLife / 100,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(filterColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getProviderColor() {
    switch (device.provider.toLowerCase()) {
      case 'xiaomi':
        return const Color(0xFFFF6900);
      case 'samsung':
        return const Color(0xFF1428A0);
      case 'philips':
        return const Color(0xFF0B5ED7);
      case 'dyson':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }
}
