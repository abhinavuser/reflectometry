import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class DataExportSection extends StatefulWidget {
  const DataExportSection({super.key});

  @override
  State<DataExportSection> createState() => _DataExportSectionState();
}

class _DataExportSectionState extends State<DataExportSection> {
  bool _isExporting = false;
  final List<Map<String, dynamic>> _recentExports = [
    {
      'name': 'alerts_2024-01-15.csv',
      'size': '2.3 MB',
      'type': 'alerts',
      'date': '2024-01-15 14:30',
    },
    {
      'name': 'tdr_analysis_2024-01-14.csv',
      'size': '1.1 MB',
      'type': 'tdr',
      'date': '2024-01-14 16:45',
    },
    {
      'name': 'predictions_2024-01-15.json',
      'size': '856 KB',
      'type': 'ai',
      'date': '2024-01-15 12:20',
    },
    {
      'name': 'rcd_events_2024-01-15.csv',
      'size': '1.8 MB',
      'type': 'rcd',
      'date': '2024-01-15 10:15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Historical Data Export',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.green800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Export Options
          Text(
            'Export Data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.green800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildExportCard(
                context,
                'Alerts',
                LucideIcons.alertTriangle,
                AppTheme.error,
                () => _handleExport('alerts'),
              ),
              _buildExportCard(
                context,
                'TDR Data',
                LucideIcons.trendingUp,
                AppTheme.info,
                () => _handleExport('tdr'),
              ),
              _buildExportCard(
                context,
                'RCD Events',
                LucideIcons.shield,
                AppTheme.warning,
                () => _handleExport('rcd'),
              ),
              _buildExportCard(
                context,
                'All Data',
                LucideIcons.download,
                AppTheme.primaryGreen,
                () => _handleExport('all'),
                isPrimary: true,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Exports
          Text(
            'Recent Exports',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.green800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ..._recentExports.map((export) => _buildExportItem(export)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return Card(
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient:
                isPrimary
                    ? LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isPrimary
                          ? Colors.white.withOpacity(0.2)
                          : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              if (_isExporting)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryGreen,
                  ),
                )
              else
                Text(
                  isPrimary ? 'Export All' : 'Export CSV',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isPrimary
                            ? Colors.white.withOpacity(0.8)
                            : color.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportItem(Map<String, dynamic> export) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              color: _getExportTypeColor(export['type']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getExportTypeIcon(export['type']),
              size: 16,
              color: _getExportTypeColor(export['type']),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  export['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.green800,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  export['date'],
                  style: const TextStyle(
                    color: AppTheme.green600,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            export['size'],
            style: const TextStyle(
              color: AppTheme.green600,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {
              // Handle download
            },
            icon: const Icon(
              LucideIcons.download,
              size: 14,
              color: AppTheme.green600,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Color _getExportTypeColor(String type) {
    switch (type) {
      case 'alerts':
        return AppTheme.error;
      case 'tdr':
        return AppTheme.info;
      case 'ai':
        return AppTheme.warning;
      case 'rcd':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.green600;
    }
  }

  IconData _getExportTypeIcon(String type) {
    switch (type) {
      case 'alerts':
        return LucideIcons.alertTriangle;
      case 'tdr':
        return LucideIcons.trendingUp;
      case 'ai':
        return LucideIcons.brain;
      case 'rcd':
        return LucideIcons.shield;
      default:
        return LucideIcons.file;
    }
  }

  Future<void> _handleExport(String type) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type data exported successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
