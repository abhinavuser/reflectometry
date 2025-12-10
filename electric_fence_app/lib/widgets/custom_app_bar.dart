import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.green200.withOpacity(0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Logo and Title
            Flexible(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      LucideIcons.zap,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SAS Electric Fence',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.green700,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Detection System',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppTheme.green600,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Status Indicators
            Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                return Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Connection Status
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                appState.isConnected
                                    ? AppTheme.success.withOpacity(0.1)
                                    : AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  appState.isConnected
                                      ? AppTheme.success.withOpacity(0.3)
                                      : AppTheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.wifi,
                                size: 12,
                                color:
                                    appState.isConnected
                                        ? AppTheme.success
                                        : AppTheme.error,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  appState.isConnected
                                      ? 'CONNECTED'
                                      : 'DISCONNECTED',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        appState.isConnected
                                            ? AppTheme.success
                                            : AppTheme.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Notifications
                      GestureDetector(
                        onTap:
                            () => _showNotificationsDialog(context, appState),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.green50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.green200),
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                LucideIcons.bell,
                                size: 16,
                                color: AppTheme.green700,
                              ),
                              if (appState.unreadNotificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: Text(
                                      '${appState.unreadNotificationCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Settings
                      GestureDetector(
                        onTap: () => _showSettingsDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.green50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.green200),
                          ),
                          child: const Icon(
                            LucideIcons.settings,
                            size: 14,
                            color: AppTheme.green700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(
    BuildContext context,
    AppStateProvider appState,
  ) {
    print('🔔 Bell icon tapped - showing notifications dialog');
    print('📊 Notifications count: ${appState.notifications.length}');
    print('📊 Unread count: ${appState.unreadNotificationCount}');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(LucideIcons.bell, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              const Text('Notifications'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: appState.notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.bell,
                          size: 48,
                          color: AppTheme.green300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.green600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Notifications will appear here when alerts are detected',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.green400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: appState.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = appState.notifications[index];
                      final isRead = notification['isRead'] ?? false;
                      final type = notification['type'] ?? 'info';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isRead ? Colors.grey[50] : Colors.white,
                        elevation: isRead ? 1 : 3,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getNotificationIcon(type),
                              color: _getNotificationColor(type),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? 'Notification',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message'] ?? ''),
                              if (notification['location'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '📍 ${notification['location']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.green600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTimestamp(notification['timestamp']),
                                style: const TextStyle(fontSize: 10),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            if (!isRead) {
                              appState.markNotificationAsRead(notification['id']);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            if (appState.notifications.isNotEmpty)
              TextButton(
                onPressed: () {
                  appState.clearAllNotifications();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'alert':
        return LucideIcons.alertTriangle;
      case 'warning':
        return LucideIcons.alertCircle;
      case 'success':
        return LucideIcons.checkCircle;
      case 'info':
        return LucideIcons.info;
      default:
        return LucideIcons.bell;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'alert':
        return AppTheme.error;
      case 'warning':
        return AppTheme.warning;
      case 'success':
        return AppTheme.success;
      case 'info':
        return AppTheme.info;
      default:
        return AppTheme.primaryGreen;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return '';
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(LucideIcons.settings, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              const Text('Settings'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.bell),
                title: const Text('Notifications'),
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              ListTile(
                leading: const Icon(LucideIcons.wifi),
                title: const Text('Auto Connect'),
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              ListTile(
                leading: const Icon(LucideIcons.moon),
                title: const Text('Dark Mode'),
                trailing: Switch(value: false, onChanged: (value) {}),
              ),
              ListTile(
                leading: const Icon(LucideIcons.download),
                title: const Text('Auto Export'),
                trailing: Switch(value: false, onChanged: (value) {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
