import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF064E3B), // emerald-900
            Color(0xFF0F766E), // teal-800
            Color(0xFF15803D), // green-700
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Floating Elements
          ...List.generate(8, (index) => _buildFloatingElement(index)),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live System',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main Title
                const Text(
                  'Electric Fence\nDetection System',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                const Text(
                  'Real-time monitoring for Kerala\'s power infrastructure',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFA7F3D0), // emerald-200
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Cards - Mobile Layout
                Consumer<AppStateProvider>(
                  builder: (context, appState, child) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '245.8',
                                'km Fence',
                                LucideIcons.zap,
                                const Color(0xFF10B981), // emerald-500
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                '98.2%',
                                'Active',
                                LucideIcons.activity,
                                const Color(0xFF14B8A6), // teal-500
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '24/7',
                                'Monitoring',
                                LucideIcons.shield,
                                const Color(0xFF22C55E), // green-500
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                '24',
                                'Alerts',
                                LucideIcons.alertTriangle,
                                const Color(0xFFF59E0B), // amber-500
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final positions = [
      const Offset(0.8, 0.2),
      const Offset(0.2, 0.4),
      const Offset(0.9, 0.6),
      const Offset(0.1, 0.8),
      const Offset(0.7, 0.1),
      const Offset(0.3, 0.7),
      const Offset(0.6, 0.9),
      const Offset(0.4, 0.3),
    ];

    final colors = [
      const Color(0xFF10B981).withOpacity(0.3),
      const Color(0xFF14B8A6).withOpacity(0.4),
      const Color(0xFF22C55E).withOpacity(0.35),
      const Color(0xFF059669).withOpacity(0.3),
      const Color(0xFF0D9488).withOpacity(0.4),
      const Color(0xFF16A34A).withOpacity(0.35),
      const Color(0xFF10B981).withOpacity(0.3),
      const Color(0xFF14B8A6).withOpacity(0.4),
    ];

    final sizes = [32.0, 20.0, 16.0, 24.0, 12.0, 28.0, 20.0, 16.0];

    return Positioned(
      left: positions[index].dx * 300,
      top: positions[index].dy * 300,
      child: Container(
        width: sizes[index],
        height: sizes[index],
        decoration: BoxDecoration(color: colors[index], shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Icon(icon, color: color, size: 4),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA7F3D0), // emerald-200
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
