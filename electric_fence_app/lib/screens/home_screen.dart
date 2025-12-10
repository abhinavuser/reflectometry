import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_section.dart';
import '../widgets/metrics_cards.dart';
import '../widgets/tdr_analysis_section.dart';
import '../widgets/ai_predictions_section.dart';
import '../widgets/rcd_monitoring_section.dart';
import '../widgets/data_export_section.dart';
import '../services/sms_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize app state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.checkConnectivity();
      appState.loadSimulatedData();
      appState.loadNotifications(); // Load notifications
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return const TDRAnalysisSection();
      case 2:
        return const AIPredictionsSection();
      case 3:
        return const RCDMonitoringSection();
      case 4:
        return const DataExportSection();
      default:
        return _buildOverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              const CustomAppBar(),

              // Main Content - Dynamic based on selected tab
              Expanded(child: _getCurrentPage()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section with Animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(opacity: value, child: const HeroSection()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Stats Row
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildQuickStatsRow(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Metrics Cards with Animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: const MetricsCards()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Real-time Alerts Section
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1400),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildRealTimeAlertsSection(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // System Performance Charts
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1600),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildSystemPerformanceSection(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Regional Analysis
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildRegionalAnalysisSection(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Simulate Open Circuit Button
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildSimulateOpenCircuitButton(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 100), // Bottom padding for navigation
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'System Analytics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.green800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        // Mobile-first layout
        Column(
          children: [
            _buildPowerDistributionCard(),
            const SizedBox(height: 12),
            _buildAlertsSummaryCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildPowerDistributionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.activity,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Power Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mobile-optimized power distribution display
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.green50, AppTheme.green100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPowerMetric('98.2%', 'Active', AppTheme.success),
                        _buildPowerMetric('1.8%', 'Fault', AppTheme.error),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time Power Distribution',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerMetric(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAlertsSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.alertTriangle,
                    color: AppTheme.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Alerts Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.green800,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      appState.alerts.take(3).map((alert) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getAlertColor(
                              alert['severity'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getAlertColor(
                                alert['severity'],
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                alert['message'],
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.mapPin,
                                    size: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      alert['location'],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Regional Analysis',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.green800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        // Mobile-first layout
        Column(
          children: [
            _buildFenceStatusCard(),
            const SizedBox(height: 12),
            _buildWeatherImpactCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildFenceStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fence Status by Region',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.green800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Operational status across Kerala districts',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.green600),
            ),
            const SizedBox(height: 16),
            _buildRegionStatus('North Kerala', 'Operational', 98),
            const SizedBox(height: 12),
            _buildRegionStatus('Central Kerala', 'Warning', 85),
            const SizedBox(height: 12),
            _buildRegionStatus('South Kerala', 'Critical', 72),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherImpactCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.cloudRain,
                    color: AppTheme.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Weather Impact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.green800,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeatherCondition(
              'Heavy Rain',
              'High',
              'Wayanad, Idukki',
              '🌧️',
            ),
            const SizedBox(height: 12),
            _buildWeatherCondition('Lightning', 'Medium', 'Palakkad', '⚡'),
            const SizedBox(height: 12),
            _buildWeatherCondition(
              'Strong Winds',
              'Low',
              'Coastal Regions',
              '💨',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionStatus(String region, String status, int health) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.green200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  region,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: health / 100,
            backgroundColor: AppTheme.green200,
            valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(health)),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '$health%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.green600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCondition(
    String condition,
    String risk,
    String areas,
    String icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.green200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  condition,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  areas,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.green600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRiskColor(risk),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              risk,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String severity) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Operational':
        return AppTheme.success;
      case 'Warning':
        return AppTheme.warning;
      case 'Critical':
        return AppTheme.error;
      default:
        return AppTheme.info;
    }
  }

  Color _getHealthColor(int health) {
    if (health > 90) return AppTheme.success;
    if (health > 80) return AppTheme.warning;
    return AppTheme.error;
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'High':
        return AppTheme.error;
      case 'Medium':
        return AppTheme.warning;
      case 'Low':
        return AppTheme.success;
      default:
        return AppTheme.info;
    }
  }

  Widget _buildQuickStatsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen.withOpacity(0.1), AppTheme.green50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.green200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStat(
              'Live',
              'System Status',
              LucideIcons.activity,
              AppTheme.success,
            ),
          ),
          Container(width: 1, height: 30, color: AppTheme.green200),
          Expanded(
            child: _buildQuickStat(
              '24/7',
              'Monitoring',
              LucideIcons.shield,
              AppTheme.info,
            ),
          ),
          Container(width: 1, height: 30, color: AppTheme.green200),
          Expanded(
            child: _buildQuickStat(
              '98.2%',
              'Uptime',
              LucideIcons.trendingUp,
              AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRealTimeAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.alertTriangle,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Real-time Alerts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.green800,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '3 Active',
                style: TextStyle(
                  color: AppTheme.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            return Column(
              children:
                  appState.alerts.take(3).map((alert) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getAlertColor(
                            alert['severity'],
                          ).withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getAlertColor(alert['severity']),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['message'],
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.mapPin,
                                      size: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert['location'],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getAlertColor(
                                          alert['severity'],
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        alert['severity'],
                                        style: TextStyle(
                                          color: _getAlertColor(
                                            alert['severity'],
                                          ),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimulateOpenCircuitButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _simulateOpenCircuit,
        icon: const Icon(LucideIcons.alertTriangle, size: 24),
        label: const Text(
          'Simulate Open Circuit Alert',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _simulateOpenCircuit() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Simulating Open Circuit...'),
          ],
        ),
      ),
    );

    try {
      // Generate random location and coordinates for Kerala
      final locations = [
        'Sector-1, Wayanad',
        'Sector-2, Idukki', 
        'Sector-3, Palakkad',
        'Sector-4, Thrissur',
        'Sector-5, Ernakulam',
      ];
      
      final coordinates = [
        '11.6851, 76.1319', // Wayanad
        '9.8497, 76.9681',  // Idukki
        '10.7867, 76.6548', // Palakkad
        '10.5168, 76.2149', // Thrissur
        '9.9312, 76.2673',  // Ernakulam
      ];

      final randomIndex = DateTime.now().millisecond % locations.length;
      final location = locations[randomIndex];
      final coordinatesStr = coordinates[randomIndex];

           // Add notification for open circuit detection
           await NotificationService.addOpenCircuitAlert(
             location: location,
             coordinates: coordinatesStr,
           );

           // Also add a test notification to ensure the system works
           await NotificationService.addNotification(
             title: '🧪 Test Notification',
             message: 'This is a test notification to verify the system is working',
             type: 'info',
           );

           // Refresh notifications in app state
           final appState = Provider.of<AppStateProvider>(context, listen: false);
           await appState.loadNotifications();

           // Send SMS alert
           final success = await SMSService.sendIllegalFenceAlert(
             location: location,
             coordinates: coordinatesStr,
           );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show result dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                success ? LucideIcons.checkCircle : LucideIcons.xCircle,
                color: success ? AppTheme.success : AppTheme.error,
              ),
              const SizedBox(width: 8),
              Text(success ? 'Alert Sent!' : 'Alert Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                success 
                  ? 'Open circuit alert has been sent via SMS to all configured recipients.'
                  : 'Failed to send open circuit alert. Please check your SMS configuration.',
              ),
              if (success) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.green50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.green200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.green800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Location: $location'),
                      Text('Coordinates: $coordinatesStr'),
                      Text('Time: ${DateTime.now().toLocal().toString().split('.')[0]}'),
                      Text('Type: Open Circuit Detection'),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(LucideIcons.xCircle, color: AppTheme.error),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text('Failed to simulate open circuit: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
