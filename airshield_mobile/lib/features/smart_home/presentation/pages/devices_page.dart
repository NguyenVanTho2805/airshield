import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/device.dart';
import '../../data/repositories/smart_home_repository.dart';
import '../bloc/smart_home_bloc.dart';
import '../widgets/device_card.dart';

/// Devices Page
/// 
/// Displays list of smart home devices with controls
class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmartHomeBloc(repository: SmartHomeRepository())
        ..add(const LoadDevices()),
      child: const _DevicesPageContent(),
    );
  }
}

class _DevicesPageContent extends StatelessWidget {
  const _DevicesPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Smart Devices',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => _showAddDeviceSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<SmartHomeBloc, SmartHomeState>(
        builder: (context, state) {
          if (state is SmartHomeLoading || state is SmartHomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            );
          }

          if (state is SmartHomeError) {
            return _buildError(context, state.message);
          }

          if (state is SmartHomeLoaded) {
            return _buildDeviceList(context, state.devices);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, List<SmartDevice> devices) {
    if (devices.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SmartHomeBloc>().add(const LoadDevices());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF4CAF50),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats header
          _buildStatsHeader(devices),
          const SizedBox(height: 24),
          // Device cards
          ...devices.map((device) => DeviceCard(
            device: device,
            onPowerToggle: () {
              context.read<SmartHomeBloc>().add(
                TogglePower(deviceId: device.deviceId),
              );
            },
            onModeChange: (mode) {
              context.read<SmartHomeBloc>().add(
                ChangeMode(deviceId: device.deviceId, mode: mode),
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(List<SmartDevice> devices) {
    final activeCount = devices.where((d) => d.isPowerOn).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.devices,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${devices.length} Devices',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$activeCount active now',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Auto',
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.devices_other,
              size: 64,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Devices Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first smart device to get started',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDeviceSheet(context),
            icon: const Icon(Icons.add),
            label: Text(
              'Add Device',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceSheet(BuildContext context) {
    final nameController = TextEditingController();
    String selectedProvider = 'xiaomi';
    final providers = ['xiaomi', 'samsung', 'philips', 'dyson'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add New Device',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Device name field
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Device Name',
                      labelStyle: GoogleFonts.poppins(color: Colors.white54),
                      prefixIcon: const Icon(Icons.devices, color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Provider selector
                  Text(
                    'Brand',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: providers.map((p) {
                      final selected = p == selectedProvider;
                      return ChoiceChip(
                        label: Text(
                          p[0].toUpperCase() + p.substring(1),
                          style: GoogleFonts.poppins(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        selected: selected,
                        selectedColor: const Color(0xFF4CAF50),
                        backgroundColor: const Color(0xFF1A1A2E),
                        side: BorderSide(
                          color: selected ? const Color(0xFF4CAF50) : Colors.white24,
                        ),
                        onSelected: (_) => setSheetState(() => selectedProvider = p),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        context.read<SmartHomeBloc>().add(
                              AddDevice(
                                deviceName: name,
                                provider: selectedProvider,
                              ),
                            );
                        Navigator.of(sheetContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add Device',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<SmartHomeBloc>().add(const LoadDevices());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
