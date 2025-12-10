export default function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  // Simulated data - replace with actual database queries
  const mapData = {
    substations: [
      { id: 'SUB001', name: 'Kochi Central', lat: 9.9312, lng: 76.2673, status: 'ACTIVE', voltage: '400kV' },
      { id: 'SUB002', name: 'Trivandrum North', lat: 8.5241, lng: 76.9366, status: 'MAINTENANCE', voltage: '220kV' },
      { id: 'SUB003', name: 'Calicut Main', lat: 11.2588, lng: 75.7804, status: 'ACTIVE', voltage: '132kV' },
      { id: 'SUB004', name: 'Thrissur East', lat: 10.5276, lng: 76.2144, status: 'ACTIVE', voltage: '220kV' },
      { id: 'SUB005', name: 'Palakkad East', lat: 10.7867, lng: 76.6548, status: 'ACTIVE', voltage: '110kV' }
    ],
    detectedFences: [
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
    ],
    powerLines: []
  };

  res.status(200).json(mapData);
}
