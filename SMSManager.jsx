// components/SMSManager.jsx
// SMS Service Management Component

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Alert, AlertDescription } from './ui/alert';
import { 
  MessageSquare, 
  Phone, 
  Send, 
  CheckCircle, 
  XCircle, 
  AlertTriangle,
  Settings,
  TestTube
} from 'lucide-react';

export default function SMSManager() {
  const [smsStatus, setSmsStatus] = useState(null);
  const [testPhoneNumber, setTestPhoneNumber] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [testResult, setTestResult] = useState(null);
  const [error, setError] = useState(null);

  // Fetch SMS service status
  const fetchSMSStatus = async () => {
    try {
      const response = await fetch('/api/sms/status');
      const data = await response.json();
      setSmsStatus(data);
    } catch (error) {
      console.error('Failed to fetch SMS status:', error);
      setError('Failed to fetch SMS status');
    }
  };

  // Send test SMS
  const sendTestSMS = async () => {
    if (!testPhoneNumber) {
      setError('Please enter a phone number');
      return;
    }

    setIsLoading(true);
    setError(null);
    setTestResult(null);

    try {
      const response = await fetch('/api/sms/send-alert', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          alertType: 'test',
          phoneNumber: testPhoneNumber
        })
      });

      const data = await response.json();
      setTestResult(data);
    } catch (error) {
      console.error('Failed to send test SMS:', error);
      setError('Failed to send test SMS');
    } finally {
      setIsLoading(false);
    }
  };

  // Send illegal fence tapping test alert
  const sendIllegalFenceTest = async () => {
    setIsLoading(true);
    setError(null);
    setTestResult(null);

    try {
      const response = await fetch('/api/sms/send-alert', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          alertType: 'openCircuit',
          testMode: true,
          readings: {
            impedance: 5000, // High impedance indicating open circuit
            voltage: 0,      // No voltage
            current: 0,      // No current
            reflectionCoeff: 0.95
          },
          location: 'Test Location - Sector 1',
          coordinates: '10.850516, 76.271083' // Kerala coordinates
        })
      });

      const data = await response.json();
      setTestResult(data);
    } catch (error) {
      console.error('Failed to send illegal fence test:', error);
      setError('Failed to send illegal fence test');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSMSStatus();
  }, []);

  const getStatusBadge = (status) => {
    if (status?.smsService?.available) {
      return <Badge className="bg-green-100 text-green-800"><CheckCircle className="w-3 h-3 mr-1" />Active</Badge>;
    } else {
      return <Badge className="bg-red-100 text-red-800"><XCircle className="w-3 h-3 mr-1" />Inactive</Badge>;
    }
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="w-5 h-5" />
            SMS Service Status
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {smsStatus ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-sm font-medium">Service Status</span>
                {getStatusBadge(smsStatus)}
              </div>
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-sm font-medium">Recipients</span>
                <span className="text-sm">{smsStatus.smsService?.recipients || 0}</span>
              </div>
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-sm font-medium">Twilio</span>
                {smsStatus.configuration?.twilioConfigured ? (
                  <Badge className="bg-green-100 text-green-800">Configured</Badge>
                ) : (
                  <Badge className="bg-red-100 text-red-800">Not Configured</Badge>
                )}
              </div>
            </div>
          ) : (
            <div className="text-center py-4">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="text-sm text-gray-500 mt-2">Loading SMS status...</p>
            </div>
          )}

          {error && (
            <Alert>
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <TestTube className="w-5 h-5" />
            Test SMS Functionality
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Test Phone Number</label>
            <div className="flex gap-2">
              <Input
                type="tel"
                placeholder="+1234567890"
                value={testPhoneNumber}
                onChange={(e) => setTestPhoneNumber(e.target.value)}
                className="flex-1"
              />
              <Button 
                onClick={sendTestSMS} 
                disabled={isLoading || !smsStatus?.smsService?.available}
                className="flex items-center gap-2"
              >
                <Send className="w-4 h-4" />
                Send Test
              </Button>
            </div>
          </div>

          <div className="flex gap-2">
            <Button 
              onClick={sendIllegalFenceTest} 
              disabled={isLoading || !smsStatus?.smsService?.available}
              variant="outline"
              className="flex items-center gap-2"
            >
              <AlertTriangle className="w-4 h-4" />
              Test Illegal Fence Alert
            </Button>
            <Button 
              onClick={fetchSMSStatus} 
              disabled={isLoading}
              variant="outline"
              className="flex items-center gap-2"
            >
              <Settings className="w-4 h-4" />
              Refresh Status
            </Button>
          </div>

          {testResult && (
            <Alert className={testResult.success ? "border-green-200 bg-green-50" : "border-red-200 bg-red-50"}>
              {testResult.success ? (
                <CheckCircle className="h-4 w-4 text-green-600" />
              ) : (
                <XCircle className="h-4 w-4 text-red-600" />
              )}
              <AlertDescription>
                <div className="space-y-2">
                  <p className="font-medium">
                    {testResult.success ? 'Test SMS Sent Successfully!' : 'Test SMS Failed'}
                  </p>
                  {testResult.results && (
                    <div className="text-sm">
                      <p>Total: {testResult.results.total}</p>
                      <p>Successful: {testResult.results.successful}</p>
                      <p>Failed: {testResult.results.failed}</p>
                    </div>
                  )}
                  {testResult.error && (
                    <p className="text-sm text-red-600">{testResult.error}</p>
                  )}
                </div>
              </AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Settings className="w-5 h-5" />
            Configuration Instructions
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="prose prose-sm max-w-none">
            <h4>Setup Steps:</h4>
            <ol className="list-decimal list-inside space-y-2">
              <li>Sign up for a Twilio account at <a href="https://www.twilio.com" target="_blank" rel="noopener noreferrer" className="text-blue-600">twilio.com</a></li>
              <li>Get your Account SID and Auth Token from the Twilio Console</li>
              <li>Purchase a phone number from Twilio</li>
              <li>Create a <code>.env.local</code> file with your credentials (see <code>env.template</code>)</li>
              <li>Add recipient phone numbers to the environment variables</li>
              <li>Restart your development server</li>
            </ol>
            
            <h4>Environment Variables Needed:</h4>
            <pre className="bg-gray-100 p-3 rounded text-xs overflow-x-auto">
{`TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890
ALERT_PHONE_NUMBER_1=+1234567890
ALERT_PHONE_NUMBER_2=+0987654321`}
            </pre>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
