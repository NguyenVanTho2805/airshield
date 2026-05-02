import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/aqi_history.dart';
import '../../data/models/aqi_forecast.dart';
import '../../data/models/dashboard_data.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../smart_home/presentation/pages/devices_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/pages/settings_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../chatbot/data/repositories/chatbot_repository.dart';
import '../../../chatbot/presentation/bloc/chatbot_bloc.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/aqi_history_chart.dart';
import '../widgets/dashboard_loading_widget.dart';
import '../widgets/dashboard_error_widget.dart';
import 'aqi_history_page.dart';

/// Dashboard Page - Main AQI Home Screen
///
/// Displays air quality information including:
/// - Current AQI value and status
/// - PM2.5, PM10, and other pollutant levels
/// - Health recommendations
/// - Quick access to smart home controls
class DashboardPage extends StatelessWidget {
  final ApiClient? apiClient;

  const DashboardPage({super.key, this.apiClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const DashboardLoadingWidget();
            }
            
            if (state is DashboardError) {
              return DashboardErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<DashboardBloc>().add(const LoadDashboardData());
                },
              );
            }
            
            if (state is DashboardLoaded) {
              return _buildContent(context, state.data, state.historyData, state.forecastData);
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openChatbot(context),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  void _openChatbot(BuildContext context) {
    final client = apiClient ?? ApiClient();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatbotBloc(
            repository: ChatbotRepository(apiClient: client),
          ),
          child: const ChatbotPage(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardData data, AqiHistoryResponse historyData, AqiForecastResponse forecastData) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboardData());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF4CAF50),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationHeader(data),
            const SizedBox(height: 24),
            _buildAqiCard(data),
            const SizedBox(height: 24),
            RepaintBoundary(
              child: AqiHistoryChart(
                historyData: historyData,
                forecastData: forecastData,
              ),
            ),
            const SizedBox(height: 24),
            _buildPollutantsGrid(data),
            const SizedBox(height: 24),
            _buildHealthRecommendation(data),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('AirShield', style: AppTextStyles.appTitle),
      actions: [
        Builder(
          builder: (context) => BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsPage()),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5252),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: AppTextStyles.tiny,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(DashboardData data) {
    final timeFormat = DateFormat('HH:mm');
    final lastUpdatedText = 'Updated: ${timeFormat.format(data.lastUpdated)}';
    
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            data.location,
            style: AppTextStyles.bodySecondary,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(lastUpdatedText, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildAqiCard(DashboardData data) {
    // Parse color from hex string
    final colorHex = data.aqiColor.replaceAll('#', '');
    final aqiColor = Color(int.parse('FF$colorHex', radix: 16));
    final aqiInfo = AqiStatusHelper.getStatusForAqi(data.aqi);
    final emoji = aqiInfo['emoji'] as String;
    
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AQIHistoryPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [aqiColor, aqiColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: aqiColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('Air Quality Index', style: AppTextStyles.aqiLabel),
              const SizedBox(height: 8),
              Text('${data.aqi}', style: AppTextStyles.aqiValue),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$emoji ${data.aqiStatus}', style: AppTextStyles.aqiBadge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollutantsGrid(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pollutants', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: data.pollutants.map((pollutant) {
            return _buildPollutantCard(
              pollutant.name,
              pollutant.value.toStringAsFixed(1),
              pollutant.unit,
              _getStatusColor(pollutant.status),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'moderate':
        return Colors.yellow;
      case 'unhealthy':
        return Colors.orange;
      case 'very_unhealthy':
        return Colors.red;
      case 'hazardous':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPollutantCard(String name, String value, String unit, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.pollutantName),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AppTextStyles.pollutantValue),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: AppTextStyles.pollutantUnit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecommendation(DashboardData data) {
    final aqiInfo = AqiStatusHelper.getStatusForAqi(data.aqi);
    final colorHex = (aqiInfo['color'] as String).replaceAll('#', '');
    final statusColor = Color(int.parse('FF$colorHex', radix: 16));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Recommendation', style: AppTextStyles.labelStrong),
                const SizedBox(height: 4),
                Text(data.healthRecommendation, style: AppTextStyles.captionSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.air,
                label: 'Air Purifier',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DevicesPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.map_outlined,
                label: 'AQI Map',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MapPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: AppTextStyles.navLabel,
        unselectedLabelStyle: AppTextStyles.navLabel,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Home
              break;
            case 1:
              // Navigate to Map
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapPage()),
              );
              break;
            case 2:
              // Navigate to Devices
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DevicesPage()),
              );
              break;
            case 3:
              // Navigate to Profile
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_outlined),
            activeIcon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
