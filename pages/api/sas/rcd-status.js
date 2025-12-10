// pages/api/sas/rcd-status.js
// RCD Status API endpoint

export default function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  // Simulate RCD monitoring data
  const generateRCDStatus = () => {
    const sectors = ['Sector-1', 'Sector-2', 'Sector-3', 'Sector-4', 'Sector-5', 'Sector-6', 'Sector-7'];
    const events = [];
    const statusSummary = {
      totalRCDs: 156,
      activeRCDs: 154,
      faultedRCDs: 2,
      recentTrips: 0,
      totalTripsToday: 3
    };
    
    // Generate recent events
    for (let i = 0; i < 10; i++) {
      const eventTime = new Date(Date.now() - (Math.random() * 3600000 * 24)); // Last 24 hours
      const sector = sectors[Math.floor(Math.random() * sectors.length)];
      const leakageCurrent = Math.random() * 50;
      const status = leakageCurrent > 30 ? 'ALERT' : 'NORMAL';
      
      if (status === 'ALERT') statusSummary.recentTrips++;
      
      events.push({
        eventId: `RCD_${Date.now()}_${i}`,
        timestamp: eventTime.toISOString(),
        location: sector,
        rcdId: `RCD_${sector.split('-')[1]}_${Math.floor(Math.random() * 10) + 1}`,
        status,
        leakageCurrentMa: Math.round(leakageCurrent * 10) / 10,
        tripTime: status === 'ALERT' ? Math.floor(Math.random() * 25) + 5 : null,
        resetRequired: status === 'ALERT',
        severity: status === 'ALERT' ? (leakageCurrent > 40 ? 'CRITICAL' : 'HIGH') : 'NORMAL'
      });
    }
    
    // Sort events by timestamp (most recent first)
    events.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    
    return {
      timestamp: new Date().toISOString(),
      statusSummary,
      recentEvents: events.slice(0, 8), // Last 8 events
      sectorStatus: sectors.map(sector => ({
        sectorId: sector,
        rcdsInstalled: Math.floor(Math.random() * 30) + 15,
        rcdsActive: Math.floor(Math.random() * 30) + 14,
        lastTrip: Math.random() > 0.7 ? new Date(Date.now() - Math.random() * 86400000 * 7).toISOString() : null,
        averageLeakage: Math.round((Math.random() * 20 + 5) * 10) / 10
      })),
      recommendations: generateRCDRecommendations(events, statusSummary)
    };
  };

  const generateRCDRecommendations = (events, summary) => {
    const recommendations = [];
    const alertEvents = events.filter(e => e.status === 'ALERT');
    
    if (alertEvents.length > 2) {
      recommendations.push('Multiple RCD activations detected - investigate potential safety hazards');
    }
    
    if (summary.faultedRCDs > 0) {
      recommendations.push(`${summary.faultedRCDs} RCD(s) require maintenance - schedule inspection`);
    }
    
    if (summary.totalTripsToday > 5) {
      recommendations.push('High number of daily trips - check for systematic issues');
    }
    
    recommendations.push('Perform monthly RCD testing as per safety standards');
    recommendations.push('Maintain RCD response time logs for compliance');
    
    return recommendations;
  };

  try {
    const rcdData = generateRCDStatus();
    res.status(200).json(rcdData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch RCD status' });
  }
}
