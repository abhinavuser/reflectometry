import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/notification_service.dart';

class AppStateProvider extends ChangeNotifier {
  // Connection Status
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isConnected = false;

  // App State
  bool _isLoading = false;
  String _currentTab = 'overview';
  DateTime _lastUpdate = DateTime.now();

  // Data
  Map<String, dynamic> _realtimeData = {};
  List<Map<String, dynamic>> _alerts = [];
  Map<String, dynamic> _tdrData = {};
  Map<String, dynamic> _aiPredictions = {};
  Map<String, dynamic> _rcdStatus = {};
  
  // Notifications
  List<Map<String, dynamic>> _notifications = [];

  // Getters
  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get currentTab => _currentTab;
  DateTime get lastUpdate => _lastUpdate;
  Map<String, dynamic> get realtimeData => _realtimeData;
  List<Map<String, dynamic>> get alerts => _alerts;
  Map<String, dynamic> get tdrData => _tdrData;
  Map<String, dynamic> get aiPredictions => _aiPredictions;
  Map<String, dynamic> get rcdStatus => _rcdStatus;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n['isRead']).length;

  // Connection Management
  Future<void> checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      _connectionStatus =
          connectivityResults.isNotEmpty
              ? connectivityResults.first
              : ConnectivityResult.none;
      _isConnected = _connectionStatus != ConnectivityResult.none;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  // Tab Management
  void setCurrentTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  // Loading State
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Data Updates
  void updateRealtimeData(Map<String, dynamic> data) {
    _realtimeData = data;
    _lastUpdate = DateTime.now();
    notifyListeners();
  }

  void updateAlerts(List<Map<String, dynamic>> newAlerts) {
    _alerts = newAlerts;
    notifyListeners();
  }

  void updateTdrData(Map<String, dynamic> data) {
    _tdrData = data;
    notifyListeners();
  }

  void updateAiPredictions(Map<String, dynamic> data) {
    _aiPredictions = data;
    notifyListeners();
  }

  void updateRcdStatus(Map<String, dynamic> data) {
    _rcdStatus = data;
    notifyListeners();
  }

  // Notification Management
  Future<void> loadNotifications() async {
    await NotificationService.initialize();
    _notifications = NotificationService.getAllNotifications();
    notifyListeners();
  }

  Future<void> addNotification(Map<String, dynamic> notification) async {
    await NotificationService.addNotification(
      title: notification['title'],
      message: notification['message'],
      type: notification['type'],
      location: notification['location'],
      coordinates: notification['coordinates'],
      additionalData: notification['additionalData'],
    );
    _notifications = NotificationService.getAllNotifications();
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await NotificationService.markAsRead(notificationId);
    _notifications = NotificationService.getAllNotifications();
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    await NotificationService.markAllAsRead();
    _notifications = NotificationService.getAllNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    await NotificationService.deleteNotification(notificationId);
    _notifications = NotificationService.getAllNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    await NotificationService.clearAllNotifications();
    _notifications = [];
    notifyListeners();
  }

  // Simulated Data for Demo
  void loadSimulatedData() {
    setLoading(true);

    // Simulate API delay
    Future.delayed(const Duration(seconds: 2), () {
      // Simulate realtime data
      _realtimeData = {
        'totalFenceLength': 245.8,
        'activeMonitoring': 98.2,
        'fenceBreaches': 24,
        'powerConsumption': 4.2,
        'recentIntrusions': [
          {
            'location': 'Wayanad Sector 3',
            'timestamp':
                DateTime.now()
                    .subtract(const Duration(minutes: 15))
                    .toIso8601String(),
            'severity': 'high',
          },
          {
            'location': 'Palakkad Sector 1',
            'timestamp':
                DateTime.now()
                    .subtract(const Duration(minutes: 45))
                    .toIso8601String(),
            'severity': 'medium',
          },
          {
            'location': 'Idukki Sector 7',
            'timestamp':
                DateTime.now()
                    .subtract(const Duration(minutes: 120))
                    .toIso8601String(),
            'severity': 'low',
          },
        ],
        'powerMetrics': List.generate(
          24,
          (i) => {
            'time': '${i}:00',
            'voltage': 220 + (i * 0.5) + (i % 3 == 0 ? 5 : 0),
            'current': 150 + (i * 0.8) + (i % 4 == 0 ? 10 : 0),
          },
        ),
      };

      // Clear mock alerts - use real notifications instead
      _alerts = [];

      // Simulate TDR data
      _tdrData = {
        'reflectionData': List.generate(
          50,
          (i) => {
            'distance': i * 100.0,
            'reflection': -20 + (i * 0.5) + (i % 10 == 0 ? 10 : 0),
            'impedance': 50 + (i * 0.2) + (i % 15 == 0 ? 5 : 0),
          },
        ),
        'detectedAnomalies': [
          {
            'anomalyType': 'CABLE_BREAK',
            'distance': 3200.0,
            'severity': 'CRITICAL',
            'confidence': 95.5,
            'recommendedAction': 'IMMEDIATE_INSPECTION',
          },
          {
            'anomalyType': 'MOISTURE_INTRUSION',
            'distance': 7500.0,
            'severity': 'HIGH',
            'confidence': 78.3,
            'recommendedAction': 'SCHEDULED_MAINTENANCE',
          },
        ],
      };

      // Simulate AI predictions
      _aiPredictions = {
        'predictions': List.generate(
          12,
          (i) => {
            'futureHour': i + 1,
            'predictedVoltage': 220 + (i * 2) + (i % 3 == 0 ? 5 : 0),
            'predictedCurrent': 150 + (i * 1.5) + (i % 4 == 0 ? 8 : 0),
          },
        ),
        'summary': {
          'recommendations': [
            'Monitor voltage levels in Wayanad sector closely',
            'Schedule maintenance for Palakkad substation',
            'Consider upgrading RCD systems in Idukki region',
          ],
        },
        'modelMetrics': {'accuracy': 94.2, 'precision': 91.8},
      };

      // Simulate RCD status
      _rcdStatus = {
        'sectorStatus': [
          {
            'sectorId': 'North Kerala',
            'rcdsInstalled': 25,
            'rcdsActive': 24,
            'averageLeakage': 12.5,
            'lastTrip':
                DateTime.now()
                    .subtract(const Duration(hours: 2))
                    .toIso8601String(),
          },
          {
            'sectorId': 'Central Kerala',
            'rcdsInstalled': 30,
            'rcdsActive': 28,
            'averageLeakage': 18.2,
            'lastTrip':
                DateTime.now()
                    .subtract(const Duration(minutes: 45))
                    .toIso8601String(),
          },
          {
            'sectorId': 'South Kerala',
            'rcdsInstalled': 20,
            'rcdsActive': 18,
            'averageLeakage': 22.1,
            'lastTrip':
                DateTime.now()
                    .subtract(const Duration(minutes: 15))
                    .toIso8601String(),
          },
        ],
        'statusSummary': {
          'totalRCDs': 75,
          'activeRCDs': 70,
          'faultedRCDs': 5,
          'totalTripsToday': 12,
        },
        'recentEvents': [
          {
            'event': 'RCD Trip',
            'location': 'South Kerala Sector 3',
            'timestamp':
                DateTime.now()
                    .subtract(const Duration(minutes: 15))
                    .toIso8601String(),
          },
          {
            'event': 'Maintenance Complete',
            'location': 'Central Kerala Sector 1',
            'timestamp':
                DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
          },
        ],
      };

      _lastUpdate = DateTime.now();
      setLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
