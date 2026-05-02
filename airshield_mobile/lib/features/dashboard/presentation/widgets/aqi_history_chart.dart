import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/aqi_history.dart';

import '../../data/models/aqi_forecast.dart';

/// AQI History Chart Widget
/// 
/// Displays a line chart of AQI values over the last 24 hours and forecast for the next 24 hours.
class AqiHistoryChart extends StatelessWidget {
  final AqiHistoryResponse historyData;
  final AqiForecastResponse? forecastData;

  const AqiHistoryChart({
    super.key,
    required this.historyData,
    this.forecastData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AQI History & Forecast',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '48h Series',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLegendItem(const Color(0xFF4CAF50), false, 'Lịch sử'),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.amber, true, 'Dự báo'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (historyData.data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.poppins(color: Colors.white54),
        ),
      );
    }

    final historySpots = _createHistorySpots();
    final forecastSpots = _createForecastSpots(historySpots.length);
    
    final allSpots = [...historySpots, ...forecastSpots];
    final minY = allSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 10;
    final maxY = allSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 10;

    return LineChart(
      LineChartData(
        minY: minY.clamp(0, double.infinity),
        maxY: maxY.clamp(0, 200),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 6,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                DateTime? time;
                if (index >= 0 && index < historyData.data.length) {
                    time = historyData.data[index].recordedAt;
                } else if (forecastData != null && index >= historyData.data.length && index < historyData.data.length + forecastData!.data.length) {
                    time = forecastData!.data[index - historyData.data.length].recordedAt;
                }
                
                if (time == null) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('HH:mm').format(time),
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: historySpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: const Color(0xFF4CAF50),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  const Color(0xFF4CAF50).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          if (forecastSpots.isNotEmpty)
            LineChartBarData(
              spots: _getForecastPathSpots(historySpots, forecastSpots),
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.amber, // Forecast line color
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5], // Dashed line
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: const Color(0xFF1A1A2E),
            tooltipRoundedRadius: 8,
            tooltipBorder: const BorderSide(color: Colors.white24),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                int aqi = 0;
                DateTime? time;
                String prefix = "";
                
                if (index < historyData.data.length) {
                  final item = historyData.data[index];
                  time = item.recordedAt;
                  aqi = item.aqi;
                  prefix = "AQI: ";
                } else if (forecastData != null && index < historyData.data.length + forecastData!.data.length) {
                  final item = forecastData!.data[index - historyData.data.length];
                  time = item.recordedAt;
                  aqi = item.aqi;
                  prefix = "(Forecast) AQI: ";
                } else {
                    return null;
                }
                
                final timeStr = DateFormat('HH:mm').format(time);
                return LineTooltipItem(
                  '$prefix$aqi\n$timeStr',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _createHistorySpots() {
    return historyData.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.aqi.toDouble());
    }).toList();
  }
  
  List<FlSpot> _createForecastSpots(int startIndex) {
    if (forecastData == null || forecastData!.data.isEmpty) return [];
    
    return forecastData!.data.asMap().entries.map((entry) {
      return FlSpot((startIndex + entry.key).toDouble(), entry.value.aqi.toDouble());
    }).toList();
  }
  
  List<FlSpot> _getForecastPathSpots(List<FlSpot> history, List<FlSpot> forecast) {
      if (history.isEmpty || forecast.isEmpty) return forecast;
      return [history.last, ...forecast];
  }

  Widget _buildLegendItem(Color color, bool isDashed, String label) {
    final Widget line = isDashed
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 7, height: 2.5, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1))),
              const SizedBox(width: 3),
              Container(width: 7, height: 2.5, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1))),
            ],
          )
        : Container(width: 20, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1.5)));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line,
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
