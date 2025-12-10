import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Single Line Diagram
        Expanded(
          flex: 2,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substation Single Line Diagram',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.green800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Real-time status of major substations and their interconnections',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.green600),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
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
                              LucideIcons.zap,
                              size: 48,
                              color: AppTheme.green600,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Single Line Diagram\nPlaceholder',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.green600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // System Status & Quick Actions
        Expanded(
          child: Column(
            children: [
              // System Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.green800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatusItem(
                        context,
                        'System Online',
                        'Active',
                        LucideIcons.checkCircle,
                        AppTheme.success,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        context,
                        'Data Sync',
                        'Real-time',
                        LucideIcons.database,
                        AppTheme.info,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        context,
                        'Maintenance',
                        'Scheduled',
                        LucideIcons.wrench,
                        AppTheme.warning,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.green800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        context,
                        'System Settings',
                        LucideIcons.settings,
                        () {
                          // Handle settings
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        context,
                        'Export Data',
                        LucideIcons.download,
                        () {
                          // Handle export
                        },
                        isOutlined: true,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        context,
                        'Alert Settings',
                        LucideIcons.bell,
                        () {
                          // Handle alerts
                        },
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child:
          isOutlined
              ? OutlinedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 16),
                label: Text(title),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: const BorderSide(color: AppTheme.green200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )
              : ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 16),
                label: Text(title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
    );
  }
}
