// components/dashboard-components.js
import React, { useState, useEffect } from 'react';
import { AlertTriangle, Clock, MapPin, X, Zap, CheckCircle, Battery, Wifi, Shield, Activity, Download, Database } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";
import { Progress } from "./ui/progress";

// AlertsPanel Component
export const AlertsPanel = () => {
  const [alerts, setAlerts] = useState([]);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    const fetchAlerts = async () => {
      try {
        const response = await fetch('/api/sas/realtime-data');
        const data = await response.json();
        if (data.alerts) {
          setAlerts(prevAlerts => [...data.alerts, ...prevAlerts].slice(0, 50));
        }
      } catch (error) {
        console.error('Failed to fetch alerts:', error);
      }
    };

    fetchAlerts();
    const interval = setInterval(fetchAlerts, 10000);
    return () => clearInterval(interval);
  }, []);

  const getSeverityColor = (severity) => {
    switch (severity) {
      case 'CRITICAL': return 'border-destructive/50 bg-destructive/10 text-destructive';
      case 'HIGH': return 'border-orange-500/50 bg-orange-100/50 text-orange-700';
      case 'MEDIUM': return 'border-yellow-500/50 bg-yellow-100/50 text-yellow-700';
      default: return 'border-muted bg-muted/50 text-muted-foreground';
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="space-x-2">
          {['all', 'critical', 'high', 'medium'].map(f => (
            <Button
              key={f}
              variant={filter === f ? 'default' : 'outline'}
              size="sm"
              onClick={() => setFilter(f)}
              className="capitalize"
            >
              {f}
            </Button>
          ))}
        </div>
      </div>

      <div className="space-y-2 max-h-96 overflow-y-auto pr-2">
        {alerts
          .filter(alert => filter === 'all' || alert.severity.toLowerCase() === filter)
          .map((alert, index) => (
            <div
              key={alert.id || index}
              className={`p-4 rounded-lg border ${getSeverityColor(alert.severity)} transition-colors`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium">{alert.message}</div>
                  <div className="flex items-center space-x-4 text-xs mt-1">
                    <div className="flex items-center">
                      <MapPin className="w-3 h-3 mr-1" />
                      {alert.location}
                    </div>
                    <div className="flex items-center">
                      <Clock className="w-3 h-3 mr-1" />
                      {new Date(alert.timestamp).toLocaleTimeString()}
                    </div>
                  </div>
                </div>
                <Badge variant={alert.severity === 'CRITICAL' ? 'destructive' : 'outline'}>
                  {alert.severity}
                </Badge>
              </div>
            </div>
          ))}
      </div>
    </div>
  );
};

// SystemHealth Component
export const SystemHealth = () => {
  const [healthData, setHealthData] = useState({
    cpu: 0,
    memory: 0,
    storage: 0,
    network: 0,
    battery: 0,
    uptime: '0:00:00'
  });

  useEffect(() => {
    const fetchHealthData = () => {
      // Simulated health data - replace with actual API call
      setHealthData({
        cpu: Math.random() * 30 + 20,
        memory: Math.random() * 20 + 40,
        storage: Math.random() * 10 + 60,
        network: Math.random() * 40 + 50,
        battery: Math.random() * 20 + 70,
        uptime: '23:45:12'
      });
    };

    fetchHealthData();
    const interval = setInterval(fetchHealthData, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>CPU Usage</span>
            <span>{healthData.cpu.toFixed(1)}%</span>
          </div>
          <Progress value={healthData.cpu} className="h-2" />
        </div>

        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>Memory</span>
            <span>{healthData.memory.toFixed(1)}%</span>
          </div>
          <Progress value={healthData.memory} className="h-2" />
        </div>

        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>Storage</span>
            <span>{healthData.storage.toFixed(1)}%</span>
          </div>
          <Progress value={healthData.storage} className="h-2" />
        </div>

        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>Network</span>
            <span>{healthData.network.toFixed(1)}%</span>
          </div>
          <Progress value={healthData.network} className="h-2" />
        </div>
      </div>

      <div className="flex justify-between items-center pt-4 border-t">
        <div className="flex items-center">
          <Activity className="w-4 h-4 mr-2 text-muted-foreground" />
          <span className="text-sm text-muted-foreground">System Uptime: {healthData.uptime}</span>
        </div>
        <Badge variant="outline" className="h-7">
          <Battery className="w-4 h-4 mr-1" />
          {healthData.battery.toFixed(1)}%
        </Badge>
      </div>
    </div>
  );
};

// GeospatialMap Component
export const GeospatialMap = () => {
  const [mapData, setMapData] = useState({
    substations: [],
    detectedFences: [],
    powerLines: []
  });
  const [selectedFeature, setSelectedFeature] = useState(null);

  useEffect(() => {
    // Simulated map data - replace with actual API call
    const simulateMapData = () => {
      const substations = [
        { id: 'SUB001', name: 'Kochi Central', lat: 9.9312, lng: 76.2673, status: 'ACTIVE', voltage: '400kV' },
        { id: 'SUB002', name: 'Trivandrum North', lat: 8.5241, lng: 76.9366, status: 'MAINTENANCE', voltage: '220kV' },
        { id: 'SUB003', name: 'Calicut Main', lat: 11.2588, lng: 75.7804, status: 'ACTIVE', voltage: '132kV' },
        { id: 'SUB004', name: 'Thrissur East', lat: 10.5276, lng: 76.2144, status: 'ACTIVE', voltage: '220kV' },
        { id: 'SUB005', name: 'Palakkad East', lat: 10.7867, lng: 76.6548, status: 'ACTIVE', voltage: '110kV' }
      ];

      const detectedFences = [
        { 
          id: 'FENCE001', lat: 10.2, lng: 76.3, severity: 'CRITICAL', 
          confidence: 95.5, distance: 3200, detectionTime: '2024-01-15T14:32:15Z',
          substationId: 'SUB001'
        },
        { 
          id: 'FENCE002', lat: 10.6, lng: 76.1, severity: 'HIGH', 
          confidence: 78.3, distance: 7500, detectionTime: '2024-01-15T13:45:22Z',
          substationId: 'SUB002'
        },
        { 
          id: 'FENCE003', lat: 11.1, lng: 75.9, severity: 'MEDIUM', 
          confidence: 67.8, distance: 5100, detectionTime: '2024-01-15T12:15:30Z',
          substationId: 'SUB003'
        }
      ];

      return { substations, detectedFences, powerLines: [] };
    };

    setMapData(simulateMapData());
  }, []);

  const getSeverityColor = (severity) => {
    switch (severity) {
      case 'CRITICAL': return 'text-destructive bg-destructive/10';
      case 'HIGH': return 'text-orange-600 bg-orange-100';
      case 'MEDIUM': return 'text-yellow-600 bg-yellow-100';
      default: return 'text-blue-600 bg-blue-100';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'ACTIVE': return 'text-green-600 bg-green-100';
      case 'MAINTENANCE': return 'text-yellow-600 bg-yellow-100';
      case 'OFFLINE': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  return (
    <div className="space-y-4">
      <div className="relative w-full h-[500px] bg-gradient-to-br from-green-50 to-blue-50 rounded-lg overflow-hidden border">
        {/* Map Background */}
        <div className="absolute inset-0">
          <div className="absolute top-4 left-4 text-xs text-muted-foreground">Kerala State Grid</div>
        </div>

        {/* Substations */}
        {mapData.substations.map((substation) => (
          <div
            key={substation.id}
            className={`absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer ${getStatusColor(substation.status)} rounded-full p-2 shadow-lg hover:shadow-xl transition-shadow`}
            style={{
              left: `${((substation.lng - 75.5) / 1.5) * 100}%`,
              top: `${((11.5 - substation.lat) / 2.5) * 100}%`
            }}
            onClick={() => setSelectedFeature({ type: 'substation', data: substation })}
          >
            <Zap className="w-4 h-4" />
          </div>
        ))}

        {/* Detected Illegal Fences */}
        {mapData.detectedFences.map((fence) => (
          <div
            key={fence.id}
            className={`absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer ${getSeverityColor(fence.severity)} rounded-full p-2 shadow-lg hover:shadow-xl transition-shadow animate-pulse`}
            style={{
              left: `${((fence.lng - 75.5) / 1.5) * 100}%`,
              top: `${((11.5 - fence.lat) / 2.5) * 100}%`
            }}
            onClick={() => setSelectedFeature({ type: 'fence', data: fence })}
          >
            <AlertTriangle className="w-4 h-4" />
          </div>
        ))}
      </div>

      {/* Legend */}
      <div className="flex flex-wrap gap-4 text-sm">
        <div className="flex items-center">
          <div className="w-4 h-4 bg-green-100 rounded-full mr-2 flex items-center justify-center">
            <Zap className="w-3 h-3 text-green-600" />
          </div>
          <span>Active Substation</span>
        </div>
        <div className="flex items-center">
          <div className="w-4 h-4 bg-yellow-100 rounded-full mr-2 flex items-center justify-center">
            <Zap className="w-3 h-3 text-yellow-600" />
          </div>
          <span>Maintenance</span>
        </div>
        <div className="flex items-center">
          <div className="w-4 h-4 bg-destructive/10 rounded-full mr-2 flex items-center justify-center">
            <AlertTriangle className="w-3 h-3 text-destructive" />
          </div>
          <span>Critical Alert</span>
        </div>
      </div>

      {/* Selected Feature Info */}
      {selectedFeature && (
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">
              {selectedFeature.type === 'substation' ? 'Substation Details' : 'Illegal Fence Detection'}
            </CardTitle>
          </CardHeader>
          <CardContent>
            {selectedFeature.type === 'substation' ? (
              <div className="space-y-2 text-sm">
                <div className="flex items-center justify-between">
                  <strong>{selectedFeature.data.name}</strong>
                  <Badge variant={selectedFeature.data.status === 'ACTIVE' ? 'success' : 'warning'}>
                    {selectedFeature.data.status}
                  </Badge>
                </div>
                <div><strong>Voltage Level:</strong> {selectedFeature.data.voltage}</div>
                <div><strong>Coordinates:</strong> {selectedFeature.data.lat.toFixed(4)}, {selectedFeature.data.lng.toFixed(4)}</div>
              </div>
            ) : (
              <div className="space-y-2 text-sm">
                <div><strong>Detection ID:</strong> {selectedFeature.data.id}</div>
                <div className="flex items-center justify-between">
                  <strong>Severity:</strong>
                  <Badge variant={selectedFeature.data.severity === 'CRITICAL' ? 'destructive' : 'outline'}>
                    {selectedFeature.data.severity}
                  </Badge>
                </div>
                <div><strong>Confidence:</strong> {selectedFeature.data.confidence}%</div>
                <div><strong>Distance:</strong> {selectedFeature.data.distance}m from substation</div>
                <div><strong>Detected:</strong> {new Date(selectedFeature.data.detectionTime).toLocaleString()}</div>
                <div><strong>Linked Substation:</strong> {selectedFeature.data.substationId}</div>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Statistics Summary */}
      <div className="grid grid-cols-3 gap-4 mt-4 pt-4 border-t">
        <div className="text-center">
          <div className="text-2xl font-bold text-green-600">{mapData.substations.filter(s => s.status === 'ACTIVE').length}</div>
          <div className="text-xs text-muted-foreground">Active Substations</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-destructive">{mapData.detectedFences.filter(f => f.severity === 'CRITICAL').length}</div>
          <div className="text-xs text-muted-foreground">Critical Detections</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-orange-600">{mapData.detectedFences.length}</div>
          <div className="text-xs text-muted-foreground">Total Illegal Fences</div>
        </div>
      </div>
    </div>
  );
};

// DataExport Component
export const DataExport = () => {
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [loading, setLoading] = useState(false);
  const [exports, setExports] = useState([
    { id: 1, name: 'alerts_2024-01-15.csv', size: '2.3 MB', type: 'alerts' },
    { id: 2, name: 'tdr_analysis_2024-01-14.csv', size: '1.1 MB', type: 'tdr' },
    { id: 3, name: 'predictions_2024-01-15.json', size: '856 KB', type: 'ai' },
    { id: 4, name: 'rcd_events_2024-01-15.csv', size: '1.8 MB', type: 'rcd' }
  ]);

  const handleExport = async (type) => {
    setLoading(true);
    try {
      // Simulated export - replace with actual API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      console.log(`Exporting ${type} data for ${selectedDate.toISOString()}`);
    } catch (error) {
      console.error('Export failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center">
              <AlertTriangle className="w-4 h-4 mr-2" />
              Alerts
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button
              variant="outline"
              className="w-full"
              disabled={loading}
              onClick={() => handleExport('alerts')}
            >
              Export CSV
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center">
              <Activity className="w-4 h-4 mr-2" />
              TDR Data
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button
              variant="outline"
              className="w-full"
              disabled={loading}
              onClick={() => handleExport('tdr')}
            >
              Export CSV
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center">
              <Shield className="w-4 h-4 mr-2" />
              RCD Events
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button
              variant="outline"
              className="w-full"
              disabled={loading}
              onClick={() => handleExport('rcd')}
            >
              Export CSV
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center">
              <Download className="w-4 h-4 mr-2" />
              All Data
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button
              variant="default"
              className="w-full"
              disabled={loading}
              onClick={() => handleExport('all')}
            >
              Export All
            </Button>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Recent Exports</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {exports.map((exp) => (
              <div
                key={exp.id}
                className="flex items-center justify-between p-2 hover:bg-muted/50 rounded-lg transition-colors"
              >
                <div className="flex items-center">
                  <Database className="w-4 h-4 mr-2 text-muted-foreground" />
                  <span className="text-sm">{exp.name}</span>
                </div>
                <span className="text-sm text-muted-foreground">{exp.size}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
