'use client';

import { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from './ui/card';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';

export const TDRAnalysis = ({ data, isLoading }) => {
  const [anomalies, setAnomalies] = useState([]);
  const [reflectionData, setReflectionData] = useState([]);

  useEffect(() => {
    if (data) {
      setAnomalies(data.detectedAnomalies || []);
      setReflectionData(data.reflectionData || []);
    }
  }, [data]);

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="h-[400px] rounded-lg loading-shimmer"></div>
        <div className="space-y-4">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-24 rounded-lg loading-shimmer"></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Card className="hover-card">
        <CardHeader>
          <CardTitle className="text-xl">TDR Reflection Analysis</CardTitle>
          <CardDescription>Real-time cable impedance and reflection measurements</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={reflectionData} className="chart-container">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis 
                  dataKey="distance" 
                  label={{ value: 'Distance (m)', position: 'insideBottom', offset: -5 }} 
                />
                <YAxis 
                  label={{ value: 'Reflection/Impedance', angle: -90, position: 'insideLeft' }} 
                />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: 'rgba(0,0,0,0.8)', 
                    border: 'none',
                    borderRadius: '8px',
                    padding: '12px' 
                  }} 
                />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="reflection" 
                  stroke="#3b82f6" 
                  name="Reflection" 
                  strokeWidth={2}
                  dot={false}
                  activeDot={{ r: 6 }}
                />
                <Line 
                  type="monotone" 
                  dataKey="impedance" 
                  stroke="#10b981" 
                  name="Impedance" 
                  strokeWidth={2}
                  dot={false}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      {anomalies.length > 0 && (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {anomalies.map((anomaly, index) => (
            <Card key={index} className="hover-card animate-slide-in" style={{ animationDelay: `${index * 100}ms` }}>
              <CardHeader className="pb-2">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg">Anomaly Detected</CardTitle>
                  <Badge variant={
                    anomaly.severity === 'CRITICAL' ? 'destructive' : 
                    anomaly.severity === 'HIGH' ? 'warning' : 
                    'default'
                  }>
                    {anomaly.severity}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Distance</span>
                    <span className="font-medium">{anomaly.distance}m</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Reflection</span>
                    <span className="font-medium">{anomaly.reflectionDb.toFixed(2)} dB</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Impedance</span>
                    <span className="font-medium">{anomaly.impedanceOhm.toFixed(2)} Ω</span>
                  </div>
                  <div className="space-y-1">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Confidence</span>
                      <span className="font-medium">{anomaly.confidence.toFixed(1)}%</span>
                    </div>
                    <Progress value={anomaly.confidence} className="h-2" />
                  </div>
                </div>
                <div className="pt-2 border-t">
                  <span className="text-sm font-medium">Recommended Action:</span>
                  <p className="text-sm text-muted-foreground mt-1">
                    {anomaly.recommendedAction.replace(/_/g, ' ')}
                  </p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
