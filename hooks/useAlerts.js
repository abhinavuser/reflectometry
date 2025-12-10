import { useState, useEffect } from 'react';
import { toast } from 'sonner';

export const useAlerts = () => {
  const [alerts, setAlerts] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    const fetchAlerts = async () => {
      try {
        const response = await fetch('/api/sas/realtime-data');
        const data = await response.json();
        if (data.alerts) {
          const newAlerts = data.alerts.filter(alert => !alerts.find(a => a.id === alert.id));
          if (newAlerts.length > 0) {
            setAlerts(prev => [...newAlerts, ...prev].slice(0, 50));
            setUnreadCount(prev => prev + newAlerts.length);
            newAlerts.forEach(alert => {
              if (alert.severity === 'CRITICAL') {
                toast.error(`Critical Alert: ${alert.message}`, {
                  description: `Location: ${alert.location}`,
                });
              }
            });
          }
        }
      } catch (error) {
        console.error('Failed to fetch alerts:', error);
      }
    };

    fetchAlerts();
    const interval = setInterval(fetchAlerts, 10000);
    return () => clearInterval(interval);
  }, [alerts]);

  const dismissAlert = (id) => {
    setAlerts(prev => prev.filter(alert => alert.id !== id));
    setUnreadCount(prev => Math.max(0, prev - 1));
  };

  const markAllRead = () => {
    setUnreadCount(0);
  };

  const clearAll = () => {
    setAlerts([]);
    setUnreadCount(0);
  };

  return {
    alerts,
    unreadCount,
    dismissAlert,
    markAllRead,
    clearAll
  };
};
