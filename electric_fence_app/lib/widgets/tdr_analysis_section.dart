import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class TDRAnalysisSection extends StatelessWidget {
  const TDRAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Time Domain Reflectometry Analysis',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.green800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Main TDR Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (appState.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppTheme.primaryGreen,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading TDR Analysis...',
                                  style: TextStyle(
                                    color: AppTheme.green600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        // TDR Chart
                        Container(
                          height: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.green200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildTDRChart(appState),
                        ),

                        const SizedBox(height: 24),

                        // Detected Anomalies
                        if (appState.tdrData['detectedAnomalies'] != null &&
                            (appState.tdrData['detectedAnomalies'] as List)
                                .isNotEmpty) ...[
                          Text(
                            'Detected Anomalies',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: AppTheme.green800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...(appState.tdrData['detectedAnomalies'] as List).map((
                            anomaly,
                          ) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.green50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getAnomalyColor(
                                    anomaly['severity'],
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        anomaly['anomalyType']
                                                ?.toString()
                                                .replaceAll('_', ' ') ??
                                            'Unknown',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.green800,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getAnomalyColor(
                                            anomaly['severity'],
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          anomaly['severity'] ?? 'UNKNOWN',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: _getAnomalyColor(
                                              anomaly['severity'],
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Anomaly Details
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildAnomalyDetail(
                                          'Distance',
                                          '${anomaly['distance']?.toString() ?? 'N/A'}m',
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildAnomalyDetail(
                                          'Confidence',
                                          '${anomaly['confidence']?.toStringAsFixed(1) ?? 'N/A'}%',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildAnomalyDetail(
                                    'Action',
                                    anomaly['recommendedAction']
                                            ?.toString()
                                            .replaceAll('_', ' ') ??
                                        'N/A',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnomalyDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.green600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.green800,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAnomalyColor(String? severity) {
    switch (severity) {
      case 'CRITICAL':
        return AppTheme.error;
      case 'HIGH':
        return AppTheme.warning;
      case 'MEDIUM':
        return AppTheme.info;
      default:
        return AppTheme.success;
    }
  }

  Widget _buildTDRChart(AppStateProvider appState) {
    final reflectionData = appState.tdrData['reflectionData'] as List? ?? [];

    if (reflectionData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.green50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.trendingUp, size: 48, color: AppTheme.green600),
              SizedBox(height: 16),
              Text(
                'Loading TDR Data...',
                style: TextStyle(
                  color: AppTheme.green600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppTheme.green200, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: AppTheme.green200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1000,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(1)}km',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}dB',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.green200),
        ),
        minX: 0,
        maxX: 5000,
        minY: -40,
        maxY: 0,
        lineBarsData: [
          LineChartBarData(
            spots:
                reflectionData.map((data) {
                  return FlSpot(
                    (data['distance'] ?? 0).toDouble(),
                    (data['reflection'] ?? 0).toDouble(),
                  );
                }).toList(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.green600],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.3),
                  AppTheme.primaryGreen.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  'Distance: ${(touchedSpot.x / 1000).toStringAsFixed(2)}km\nReflection: ${touchedSpot.y.toStringAsFixed(1)}dB',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
