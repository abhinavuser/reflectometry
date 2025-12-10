import React from 'react';
import { Bell, X, Check, AlertTriangle, Clock, MapPin } from 'lucide-react';
import { Button } from './ui/button';
import { ScrollArea } from './ui/scroll-area';
import { useAlerts } from '../hooks/useAlerts';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from './ui/dropdown-menu';
import { Badge } from './ui/badge';

export function NotificationsMenu() {
  const { alerts, unreadCount, dismissAlert, markAllRead, clearAll } = useAlerts();

  const getSeverityColor = (severity) => {
    switch (severity.toUpperCase()) {
      case 'CRITICAL': return 'destructive';
      case 'HIGH': return 'orange';
      case 'MEDIUM': return 'yellow';
      case 'LOW': return 'default';
      default: return 'secondary';
    }
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" className="relative" size="icon">
          <Bell className="h-[1.2rem] w-[1.2rem]" />
          {unreadCount > 0 && (
            <Badge 
              variant="destructive" 
              className="absolute -top-1 -right-1 h-5 w-5 flex items-center justify-center p-0 text-xs"
            >
              {unreadCount}
            </Badge>
          )}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-[380px]">
        <DropdownMenuLabel className="flex items-center justify-between">
          <span>Notifications</span>
          <div className="flex space-x-2">
            <Button variant="ghost" size="sm" onClick={markAllRead}>
              <Check className="h-4 w-4 mr-1" />
              Mark all read
            </Button>
            <Button variant="ghost" size="sm" onClick={clearAll}>
              <X className="h-4 w-4 mr-1" />
              Clear all
            </Button>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <ScrollArea className="h-[400px] overflow-auto">
          <DropdownMenuGroup>
            {alerts.length === 0 ? (
              <div className="p-4 text-center text-muted-foreground">
                No notifications
              </div>
            ) : (
              alerts.map((alert) => (
                <DropdownMenuItem key={alert.id} className="flex flex-col p-4 focus:bg-muted/50 cursor-default">
                  <div className="flex justify-between w-full">
                    <div className="flex space-x-2">
                      <AlertTriangle className={
                        alert.severity === 'CRITICAL' ? 'text-destructive' : 
                        alert.severity === 'HIGH' ? 'text-orange-500' : 
                        'text-yellow-500'
                      } />
                      <div>
                        <div className="font-semibold">{alert.message}</div>
                        <div className="text-sm text-muted-foreground mt-1 space-y-1">
                          <div className="flex items-center">
                            <MapPin className="h-3 w-3 mr-1" />
                            {alert.location}
                          </div>
                          <div className="flex items-center">
                            <Clock className="h-3 w-3 mr-1" />
                            {new Date(alert.timestamp).toLocaleString()}
                          </div>
                        </div>
                      </div>
                    </div>
                    <Button 
                      variant="ghost" 
                      size="icon"
                      className="h-6 w-6"
                      onClick={() => dismissAlert(alert.id)}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                  <Badge 
                    variant={getSeverityColor(alert.severity)}
                    className="mt-2 self-start"
                  >
                    {alert.severity}
                  </Badge>
                </DropdownMenuItem>
              ))
            )}
          </DropdownMenuGroup>
        </ScrollArea>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
