import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class MetricsCards extends StatelessWidget {
  const MetricsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final data = appState.realtimeData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'System Metrics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.green800,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
              children: [
                _buildMetricCard(
                  context,
                  'Total Fence Length',
                  '${data['totalFenceLength']?.toString() ?? '245.8'} km',
                  'Across Kerala State',
                  LucideIcons.mapPin,
                  AppTheme.primaryGreen,
                  AppTheme.green50,
                  100.0,
                ),
                _buildMetricCard(
                  context,
                  'Active Monitoring',
                  '${data['activeMonitoring']?.toString() ?? '98.2'}%',
                  '${((data['totalFenceLength'] ?? 245.8) * (data['activeMonitoring'] ?? 98.2) / 100).toStringAsFixed(1)} km monitored',
                  LucideIcons.activity,
                  AppTheme.primaryGreen,
                  AppTheme.green50,
                  (data['activeMonitoring'] ?? 98.2).toDouble(),
                ),
                _buildMetricCard(
                  context,
                  'Fence Breaches',
                  '${data['fenceBreaches']?.toString() ?? '24'}',
                  'Last 24 hours',
                  LucideIcons.alertTriangle,
                  AppTheme.error,
                  AppTheme.error.withOpacity(0.1),
                  60.0,
                ),
                _buildMetricCard(
                  context,
                  'Power Consumption',
                  '${data['powerConsumption']?.toString() ?? '4.2'} MW',
                  'Current draw',
                  LucideIcons.zap,
                  AppTheme.info,
                  AppTheme.info.withOpacity(0.1),
                  75.0,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color backgroundColor,
    double progressValue,
  ) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressValue / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
