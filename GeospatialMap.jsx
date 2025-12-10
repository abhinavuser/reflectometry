'use client';

import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';

// Import Leaflet CSS
import 'leaflet/dist/leaflet.css';
import "leaflet-defaulticon-compatibility";
import "leaflet-defaulticon-compatibility/dist/leaflet-defaulticon-compatibility.css";

// Custom marker icons
const createMarkerIcon = (type, color) => {
  // SVG strings for different marker types
  const icons = {
    substation: `
      <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="${color}" stroke-width="2">
        <path d="M21 11V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v6h18z"/>
        <path d="M3 11v8a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-8H3z"/>
        <path d="m12 7 1.5 2h-3L12 7z"/>
        <path d="M12 17v-3"/>
        <path d="M10 14h4"/>
      </svg>
    `,
    fence: `
      <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="${color}" stroke-width="2">
        <path d="M3 8h18"/>
        <path d="M3 16h18"/>
        <path d="M4 4v16"/>
        <path d="M9 4v16"/>
        <path d="M15 4v16"/>
        <path d="M20 4v16"/>
        <path d="M12 10v4"/>
        <path d="m9 12 6 0"/>
      </svg>
    `
  };

  const svg = icons[type];
  const marker = new L.DivIcon({
    html: `
      <div class="marker-wrapper ${type}-marker" data-status="${type === 'substation' ? color === '#10B981' ? 'active' : color === '#F59E0B' ? 'maintenance' : 'critical' : 'fence'}">
        ${svg}
      </div>
    `,
    className: '',
    iconSize: [32, 32],
    iconAnchor: [16, 16],
    popupAnchor: [0, -16],
  });

  return marker;
};

const markerIcons = {
  active: createMarkerIcon('substation', '#10B981'),
  maintenance: createMarkerIcon('substation', '#F59E0B'),
  critical: createMarkerIcon('substation', '#EF4444')
};

export default function GeospatialMap() {
  const [substations, setSubstations] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchSubstations = async () => {
      try {
        // Simulated substation data - replace with actual API call
        const data = [
          {
            id: 'SUB001',
            name: 'Thiruvananthapuram Central',
            status: 'active',
            position: [8.4855, 76.9492],
            lastUpdate: new Date().toISOString(),
            metrics: {
              voltage: 230,
              current: 150,
              frequency: 50,
              power: 45,
            },
          },
          {
            id: 'SUB002',
            name: 'Kochi Distribution',
            status: 'maintenance',
            position: [9.9312, 76.2673],
            lastUpdate: new Date().toISOString(),
            metrics: {
              voltage: 220,
              current: 130,
              frequency: 49.8,
              power: 38,
            },
          },
          {
            id: 'SUB003',
            name: 'Kozhikode Grid',
            status: 'critical',
            position: [11.2588, 75.7804],
            lastUpdate: new Date().toISOString(),
            metrics: {
              voltage: 210,
              current: 180,
              frequency: 50.2,
              power: 52,
            },
          },
          // Add more substations as needed
        ];
        setSubstations(data);
        setIsLoading(false);
      } catch (error) {
        console.error('Error fetching substation data:', error);
        setIsLoading(false);
      }
    };

    fetchSubstations();
    const interval = setInterval(fetchSubstations, 30000); // Update every 30 seconds
    return () => clearInterval(interval);
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <MapContainer
      center={[10.8505, 76.2711]} // Kerala center coordinates
      zoom={7}
      style={{ height: '100%', width: '100%' }}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      {substations.map((substation) => (
        <Marker
          key={substation.id}
          position={substation.position}
          icon={markerIcons[substation.status]}
        >
          <Popup>
            <div className="p-2">
              <h3 className="font-medium">{substation.name}</h3>
              <div className="grid gap-1 mt-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Status:</span>
                  <span className={`capitalize font-medium ${
                    substation.status === 'critical' ? 'text-destructive' :
                    substation.status === 'maintenance' ? 'text-orange-500' :
                    'text-green-600'
                  }`}>{substation.status}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Voltage:</span>
                  <span>{substation.metrics.voltage}kV</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Current:</span>
                  <span>{substation.metrics.current}A</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Frequency:</span>
                  <span>{substation.metrics.frequency}Hz</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Power:</span>
                  <span>{substation.metrics.power}MW</span>
                </div>
              </div>
            </div>
          </Popup>
        </Marker>
      ))}
    </MapContainer>
  );
};
