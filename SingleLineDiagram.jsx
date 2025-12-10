'use client';

import { useState, useEffect } from 'react';
import { Badge } from './ui/badge';

export const SingleLineDiagram = () => {
  const [substations, setSubstations] = useState([
    {
      id: 'SUB1',
      name: 'Thiruvananthapuram',
      voltage: '220kV',
      current: '1000A',
      status: 'active',
      loads: ['L1', 'L2', 'L3'],
      feeders: ['F1', 'F2']
    },
    {
      id: 'SUB2',
      name: 'Kochi',
      voltage: '110kV',
      current: '800A',
      status: 'maintenance',
      loads: ['L4', 'L5'],
      feeders: ['F3']
    },
    {
      id: 'SUB3',
      name: 'Kozhikode',
      voltage: '220kV',
      current: '1200A',
      status: 'critical',
      loads: ['L6', 'L7', 'L8'],
      feeders: ['F4', 'F5']
    }
  ]);

  const getStatusColor = (status) => {
    switch (status) {
      case 'active':
        return 'bg-green-500';
      case 'maintenance':
        return 'bg-yellow-500';
      case 'critical':
        return 'bg-red-500';
      default:
        return 'bg-gray-500';
    }
  };

  return (
    <div className="w-full h-full min-h-[400px] relative p-4">
      <svg width="100%" height="100%" viewBox="0 0 1000 600" className="overflow-visible">
        {/* Grid Background */}
        <defs>
          <pattern id="grid" width="50" height="50" patternUnits="userSpaceOnUse">
            <path d="M 50 0 L 0 0 0 50" fill="none" stroke="rgba(0,0,0,0.1)" strokeWidth="0.5"/>
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" />

        {/* Main Bus */}
        <line x1="100" y1="100" x2="900" y2="100" stroke="#2563eb" strokeWidth="4"/>
        
        {/* Substations */}
        {substations.map((sub, index) => {
          const x = 200 + (index * 300);
          return (
            <g key={sub.id}>
              {/* Substation Symbol */}
              <circle 
                cx={x} 
                cy="100" 
                r="20" 
                className={`${getStatusColor(sub.status)} stroke-2 stroke-white`}
              />
              
              {/* Substation Label */}
              <text x={x} y="150" textAnchor="middle" className="text-sm font-medium">
                {sub.name}
              </text>
              
              {/* Voltage Label */}
              <text x={x} y="170" textAnchor="middle" className="text-xs text-muted-foreground">
                {sub.voltage}
              </text>

              {/* Feeders */}
              {sub.feeders.map((feeder, i) => {
                const fx = x - 20 + (i * 40);
                return (
                  <g key={feeder}>
                    <line 
                      x1={fx} 
                      y1="100" 
                      x2={fx} 
                      y2="200" 
                      stroke="#2563eb" 
                      strokeWidth="2"
                    />
                    <circle 
                      cx={fx} 
                      cy="200" 
                      r="5" 
                      fill="#2563eb"
                    />
                  </g>
                );
              })}

              {/* Loads */}
              {sub.loads.map((load, i) => {
                const lx = x - 40 + (i * 40);
                return (
                  <g key={load}>
                    <line 
                      x1={lx} 
                      y1="100" 
                      x2={lx} 
                      y2="250" 
                      stroke="#2563eb" 
                      strokeWidth="2"
                    />
                    <path
                      d={`M ${lx-10} 250 L ${lx+10} 250 L ${lx} 270 Z`}
                      fill="#2563eb"
                    />
                  </g>
                );
              })}
            </g>
          );
        })}

        {/* Interconnections */}
        {substations.slice(0, -1).map((_, index) => {
          const x1 = 300 + (index * 300);
          const x2 = x1 + 100;
          return (
            <g key={`conn-${index}`}>
              <line 
                x1={x1} 
                y1="100" 
                x2={x2} 
                y2="100" 
                stroke="#2563eb" 
                strokeWidth="4"
                strokeDasharray="5,5"
              />
            </g>
          );
        })}
      </svg>

      {/* Legend */}
      <div className="absolute top-4 right-4 bg-background/90 backdrop-blur-sm p-4 rounded-lg border space-y-2">
        <div className="text-sm font-medium">Status Legend</div>
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-green-500"/>
            <span className="text-sm">Operational</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-yellow-500"/>
            <span className="text-sm">Maintenance</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-red-500"/>
            <span className="text-sm">Critical</span>
          </div>
        </div>
      </div>
    </div>
  );
};
