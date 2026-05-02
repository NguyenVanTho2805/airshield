import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/device.dart';
import '../../data/models/device_activity.dart';
import '../../data/repositories/smart_home_repository.dart';
import '../bloc/smart_home_bloc.dart';

/// Device Details Page
/// 
/// Shows detailed information about a smart device including real-time stats and activity history
class DeviceDetailsPage extends StatefulWidget {
  final SmartDevice device;

  const DeviceDetailsPage({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  late SmartHomeRepository _repository;
  List<DeviceActivity> _activities = [];
  bool _isLoadingActivities = true;

  @override
  void initState() {
    super.initState();
    _repository = SmartHomeRepository();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await _repository.getDeviceActivities(widget.device.deviceId);
      setState(() {
        _activities = activities;
        _isLoadingActivities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingActivities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartHomeBloc, SmartHomeState>(
      builder: (context, state) {
        // Get updated device from state
        final SmartDevice currentDevice;
        if (state is SmartHomeLoaded) {
          currentDevice = state.devices.firstWhere(
            (d) => d.deviceId == widget.device.deviceId,
            orElse: () => widget.device,
          );
        } else {
          currentDevice = widget.device;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            title: Text(
              currentDevice.deviceName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => _showRenameDialog(context, currentDevice),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadActivities,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(currentDevice),
                const SizedBox(height: 24),
                _buildControls(currentDevice),
                const SizedBox(height: 24),
                _buildStats(currentDevice),
                const SizedBox(height: 24),
                _buildActivityTimeline(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, SmartDevice device) {
    final controller = TextEditingController(text: device.deviceName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Rename Device',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            labelText: 'Device Name',
            labelStyle: GoogleFonts.poppins(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == device.deviceName) {
                Navigator.of(dialogContext).pop();
                return;
              }
              context.read<SmartHomeBloc>().add(
                    RenameDevice(deviceId: device.deviceId, newName: newName),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SmartDevice device) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: device.isPowerOn
              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
              : [const Color(0xFF424242), const Color(0xFF212121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular (20),
        boxShadow: [
          BoxShadow(
            color: (device.isPowerOn ? const Color(0xFF4CAF50) : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Device Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              device.mode.icon,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),
          
          // Status
          Text(
            device.isPowerOn ? 'Online' : 'Offline',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Current Mode
          if (device.isPowerOn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                device.mode.getDisplayName(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(SmartDevice device) {
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
            'Controls',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          // Power Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.power_settings_new,
                    color: device.isPowerOn
                        ? const Color(0xFF4CAF50)
                        : Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Power',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Switch(
                value: device.isPowerOn,
                onChanged: (_) {
                  context.read<SmartHomeBloc>().add(
                        TogglePower(deviceId: device.deviceId),
                      );
                },
                thumbColor: WidgetStateProperty.all(
                  device.isPowerOn ? const Color(0xFF4CAF50) : Colors.grey,
                ),
                trackColor: WidgetStateProperty.all(
                  device.isPowerOn
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          
          if (device.isPowerOn) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Mode Selection
            Text(
              'Mode',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DeviceMode.values.map((mode) {
                final isSelected = device.mode == mode;
                return InkWell(
                  onTap: () {
                    context.read<SmartHomeBloc>().add(
                          ChangeMode(deviceId: device.deviceId, mode: mode),
                        );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mode.icon,
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mode.getDisplayName(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(SmartDevice device) {
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
            'Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Filter Life',
                  '${device.filterLife}%',
                  Icons.air,
                  _parseColor(device.filterStatusColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Uptime',
                  '8h 32m',
                  Icons.schedule,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Energy',
                  '2.4 kWh',
                  Icons.bolt,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Provider',
                  device.providerDisplayName,
                  Icons.business,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
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
            'Activity Timeline',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isLoadingActivities)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No activities yet',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            )
          else
            ..._activities.map((activity) => _buildActivityItem(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(DeviceActivity activity) {
    final timeAgo = _getTimeAgo(activity.timestamp);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.activityType).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(activity.activityType),
              size: 16,
              color: _getActivityColor(activity.activityType),
            ),
          ),
          const SizedBox(width: 12),
          
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.powerOn:
        return Icons.power_settings_new;
      case ActivityType.powerOff:
        return Icons.power_off;
      case ActivityType.modeChange:
        return Icons.tune;
      case ActivityType.filterReplacement:
        return Icons.filter_alt;
      case ActivityType.maintenance:
        return Icons.build;
      case ActivityType.alert:
        return Icons.warning;
      case ActivityType.statusUpdate:
        return Icons.info;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.powerOn:
        return const Color(0xFF4CAF50);
      case ActivityType.powerOff:
        return const Color(0xFF757575);
      case ActivityType.modeChange:
        return const Color(0xFF2196F3);
      case ActivityType.filterReplacement:
        return const Color(0xFFFF9800);
      case ActivityType.maintenance:
        return const Color(0xFF9C27B0);
      case ActivityType.alert:
        return const Color(0xFFF44336);
      case ActivityType.statusUpdate:
        return const Color(0xFF00BCD4);
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
