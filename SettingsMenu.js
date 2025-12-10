import React from 'react';
import { Settings, User, Bell, Shield, Database, Laptop } from 'lucide-react';
import { Button } from './ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
  DropdownMenuSub,
  DropdownMenuSubTrigger,
  DropdownMenuSubContent,
  DropdownMenuPortal,
} from './ui/dropdown-menu';
import { Switch } from './ui/switch';

export function SettingsMenu() {
  const [settings, setSettings] = React.useState({
    notifications: {
      alerts: true,
      updates: true,
      maintenance: true,
    },
    security: {
      twoFactor: false,
      biometric: false,
    },
    system: {
      darkMode: false,
      autoUpdate: true,
      telemetry: true,
    }
  });

  const updateSetting = (category, setting, value) => {
    setSettings(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [setting]: value
      }
    }));
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon">
          <Settings className="h-[1.2rem] w-[1.2rem]" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-[280px]">
        <DropdownMenuLabel>Settings</DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuGroup>
          {/* Profile Settings */}
          <DropdownMenuSub>
            <DropdownMenuSubTrigger>
              <User className="mr-2 h-4 w-4" />
              <span>Profile</span>
            </DropdownMenuSubTrigger>
            <DropdownMenuPortal>
              <DropdownMenuSubContent>
                <DropdownMenuItem>
                  View Profile
                </DropdownMenuItem>
                <DropdownMenuItem>
                  Edit Profile
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem>
                  Change Password
                </DropdownMenuItem>
              </DropdownMenuSubContent>
            </DropdownMenuPortal>
          </DropdownMenuSub>

          {/* Notification Settings */}
          <DropdownMenuSub>
            <DropdownMenuSubTrigger>
              <Bell className="mr-2 h-4 w-4" />
              <span>Notifications</span>
            </DropdownMenuSubTrigger>
            <DropdownMenuPortal>
              <DropdownMenuSubContent>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Critical Alerts</span>
                  <Switch 
                    checked={settings.notifications.alerts}
                    onCheckedChange={(checked) => updateSetting('notifications', 'alerts', checked)}
                  />
                </DropdownMenuItem>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>System Updates</span>
                  <Switch 
                    checked={settings.notifications.updates}
                    onCheckedChange={(checked) => updateSetting('notifications', 'updates', checked)}
                  />
                </DropdownMenuItem>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Maintenance</span>
                  <Switch 
                    checked={settings.notifications.maintenance}
                    onCheckedChange={(checked) => updateSetting('notifications', 'maintenance', checked)}
                  />
                </DropdownMenuItem>
              </DropdownMenuSubContent>
            </DropdownMenuPortal>
          </DropdownMenuSub>

          {/* Security Settings */}
          <DropdownMenuSub>
            <DropdownMenuSubTrigger>
              <Shield className="mr-2 h-4 w-4" />
              <span>Security</span>
            </DropdownMenuSubTrigger>
            <DropdownMenuPortal>
              <DropdownMenuSubContent>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Two-Factor Auth</span>
                  <Switch 
                    checked={settings.security.twoFactor}
                    onCheckedChange={(checked) => updateSetting('security', 'twoFactor', checked)}
                  />
                </DropdownMenuItem>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Biometric Login</span>
                  <Switch 
                    checked={settings.security.biometric}
                    onCheckedChange={(checked) => updateSetting('security', 'biometric', checked)}
                  />
                </DropdownMenuItem>
              </DropdownMenuSubContent>
            </DropdownMenuPortal>
          </DropdownMenuSub>

          {/* System Settings */}
          <DropdownMenuSub>
            <DropdownMenuSubTrigger>
              <Laptop className="mr-2 h-4 w-4" />
              <span>System</span>
            </DropdownMenuSubTrigger>
            <DropdownMenuPortal>
              <DropdownMenuSubContent>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Dark Mode</span>
                  <Switch 
                    checked={settings.system.darkMode}
                    onCheckedChange={(checked) => updateSetting('system', 'darkMode', checked)}
                  />
                </DropdownMenuItem>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Auto Updates</span>
                  <Switch 
                    checked={settings.system.autoUpdate}
                    onCheckedChange={(checked) => updateSetting('system', 'autoUpdate', checked)}
                  />
                </DropdownMenuItem>
                <DropdownMenuItem className="flex items-center justify-between">
                  <span>Send Telemetry</span>
                  <Switch 
                    checked={settings.system.telemetry}
                    onCheckedChange={(checked) => updateSetting('system', 'telemetry', checked)}
                  />
                </DropdownMenuItem>
              </DropdownMenuSubContent>
            </DropdownMenuPortal>
          </DropdownMenuSub>

          {/* Data Management */}
          <DropdownMenuSub>
            <DropdownMenuSubTrigger>
              <Database className="mr-2 h-4 w-4" />
              <span>Data</span>
            </DropdownMenuSubTrigger>
            <DropdownMenuPortal>
              <DropdownMenuSubContent>
                <DropdownMenuItem>
                  Export Data
                </DropdownMenuItem>
                <DropdownMenuItem>
                  Import Data
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="text-destructive">
                  Clear All Data
                </DropdownMenuItem>
              </DropdownMenuSubContent>
            </DropdownMenuPortal>
          </DropdownMenuSub>
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
