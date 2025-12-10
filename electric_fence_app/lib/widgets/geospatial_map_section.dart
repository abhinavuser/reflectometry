import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class GeospatialMapSection extends StatelessWidget {
  const GeospatialMapSection({super.key});

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
                'Kerala Power Grid - Geospatial View',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.green800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Map Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map Container
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: AppTheme.green50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.green200),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.map,
                                size: 64,
                                color: AppTheme.green600,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Interactive Map\nPlaceholder',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.green600,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Kerala State Grid with Substations\nand Fence Detection Points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.green500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Legend
                      Text(
                        'Legend',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.green800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildLegendItem(
                            LucideIcons.zap,
                            'Active Substation',
                            AppTheme.success,
                          ),
                          const SizedBox(width: 24),
                          _buildLegendItem(
                            LucideIcons.zap,
                            'Maintenance',
                            AppTheme.warning,
                          ),
                          const SizedBox(width: 24),
                          _buildLegendItem(
                            LucideIcons.alertTriangle,
                            'Critical Alert',
                            AppTheme.error,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Statistics Summary
                      Text(
                        'Grid Statistics',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.green800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '4',
                              'Active Substations',
                              AppTheme.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatItem(
                              '2',
                              'Critical Detections',
                              AppTheme.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatItem(
                              '3',
                              'Total Illegal Fences',
                              AppTheme.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Substation Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Substation Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.green800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildSubstationItem(
                        'Kochi Central',
                        'ACTIVE',
                        '400kV',
                        '9.9312, 76.2673',
                        AppTheme.success,
                      ),
                      const SizedBox(height: 12),
                      _buildSubstationItem(
                        'Trivandrum North',
                        'MAINTENANCE',
                        '220kV',
                        '8.5241, 76.9366',
                        AppTheme.warning,
                      ),
                      const SizedBox(height: 12),
                      _buildSubstationItem(
                        'Calicut Main',
                        'ACTIVE',
                        '132kV',
                        '11.2588, 75.7804',
                        AppTheme.success,
                      ),
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

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.green700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstationItem(
    String name,
    String status,
    String voltage,
    String coordinates,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.green200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(LucideIcons.zap, size: 16, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.green800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Voltage: $voltage',
                  style: const TextStyle(
                    color: AppTheme.green600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Coordinates: $coordinates',
                  style: const TextStyle(
                    color: AppTheme.green600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

