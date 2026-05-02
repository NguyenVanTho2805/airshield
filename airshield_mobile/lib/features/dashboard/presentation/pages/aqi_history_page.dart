import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/aqi_data_point.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../bloc/aqi_history_bloc.dart';

/// AQI History Page
/// 
/// Shows historical AQI data with charts and time range selection
class AQIHistoryPage extends StatelessWidget {
  const AQIHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AQIHistoryBloc(
        repository: DashboardRepository.mock(),
      )..add(const LoadAQIHistory(TimeRange.today)),
      child: const _AQIHistoryView(),
    );
  }
}

class _AQIHistoryView extends StatelessWidget {
  const _AQIHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'AQI History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: BlocBuilder<AQIHistoryBloc, AQIHistoryState>(
        builder: (context, state) {
          if (state is AQIHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AQIHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (state is AQIHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AQIHistoryBloc>().add(
                      LoadAQIHistory(state.timeRange),
                    );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTimeRangeSelector(context, state.timeRange),
                  const SizedBox(height: 24),
                  _buildAQIChart(context, state.dataPoints, state.timeRange),
                  const SizedBox(height: 24),
                  _buildPollutantCharts(context, state.dataPoints),
                  const SizedBox(height: 24),
                  _buildStatsSummary(context, state.dataPoints),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, TimeRange selectedRange) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = range == selectedRange;
          return Expanded(
            child: InkWell(
              onTap: () {
                context.read<AQIHistoryBloc>().add(ChangeTimeRange(range));
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  range.displayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAQIChart(
    BuildContext context,
    List<AQIDataPoint> dataPoints,
    TimeRange timeRange,
  ) {
    if (dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxAQI = dataPoints.map((d) => d.aqi).reduce((a, b) => a > b ? a : b);
    final minAQI = dataPoints.map((d) => d.aqi).reduce((a, b) => a < b ? a : b);

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
            'AQI Trend',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: dataPoints.length > 10 ? dataPoints.length / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < 0 || value.toInt() >= dataPoints.length) {
                          return const SizedBox.shrink();
                        }
                        final dataPoint = dataPoints[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _formatBottomTitle(dataPoint.timestamp, timeRange),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: (maxAQI + 50).toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.aqi.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: dataPoints.length <= 24,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: dataPoints[index].getStatusColor(),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dataPoint = dataPoints[spot.x.toInt()];
                        return LineTooltipItem(
                          'AQI: ${dataPoint.aqi}\n${dataPoint.status}\n${DateFormat('MMM d, HH:mm').format(dataPoint.timestamp)}',
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantCharts(BuildContext context, List<AQIDataPoint> dataPoints) {
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
            'Pollutant Levels',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPollutantMiniChart(
                  context,
                  'PM2.5',
                  dataPoints.map((d) => d.pm25).toList(),
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPollutantMiniChart(
                  context,
                  'PM10',
                  dataPoints.map((d) => d.pm10).toList(),
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantMiniChart(
    BuildContext context,
    String name,
    List<double> values,
    Color color,
  ) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxValue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: values.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${values.last.toStringAsFixed(1)} μg/m³',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, List<AQIDataPoint> dataPoints) {
    final avgAQI = (dataPoints.map((d) => d.aqi).reduce((a, b) => a + b) / dataPoints.length).round();
    final maxAQI = dataPoints.map((d) => d.aqi).reduce((a, b) => a > b ? a : b);
    final minAQI = dataPoints.map((d) => d.aqi).reduce((a, b) => a < b ? a : b);

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
                child: _buildStatItem(
                  context,
                  'Average',
                  avgAQI.toString(),
                  Icons.analytics,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Maximum',
                  maxAQI.toString(),
                  Icons.trending_up,
                  const Color(0xFFF44336),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Minimum',
                  minAQI.toString(),
                  Icons.trending_down,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
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

  String _formatBottomTitle(DateTime timestamp, TimeRange timeRange) {
    switch (timeRange) {
      case TimeRange.today:
        return DateFormat('HH:mm').format(timestamp);
      case TimeRange.week:
        return DateFormat('E').format(timestamp); // Mon, Tue, etc
      case TimeRange.month:
        return DateFormat('d').format(timestamp); // 1, 2, 3, etc
    }
  }
}
