import { useState, useEffect } from "react"
import Head from "next/head"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "../components/ui/card"
import { SingleLineDiagram } from "../components/SingleLineDiagram"
import { Badge } from "../components/ui/badge"
import { Button } from "../components/ui/button"
import { Progress } from "../components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs"
import {
  Activity,
  Zap,
  Shield,
  AlertTriangle,
  Eye,
  Settings,
  Bell,
  LineChart,
  Wifi,
  Brain,
  MapPin,
  Download,
  Clock,
  Search
} from "lucide-react"
import { LineChart as RechartsLineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar } from 'recharts'
import { AlertsPanel, SystemHealth, DataExport } from '../components/dashboard-components'
import { MapWrapper } from '../components/MapWrapper'
import { NotificationsMenu } from '../components/NotificationsMenu'
import { SettingsMenu } from '../components/SettingsMenu'
import { useAlerts } from '../hooks/useAlerts'
import { Input } from '../components/ui/input'
import { ErrorBoundary } from '../components/error-boundary'
import { TDRAnalysis } from '../components/TDRAnalysis'
import SMSManager from '../components/SMSManager'
export default function SASElectricFenceDetection() {
  const [currentTime, setCurrentTime] = useState(new Date())
  const [connectionStatus, setConnectionStatus] = useState('CONNECTING')
  const [activeTab, setActiveTab] = useState('overview')
  const [searchQuery, setSearchQuery] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [alertCount, setAlertCount] = useState(0)
  
  // State for realtime data
  const [data, setData] = useState([])
  const [tdrData, setTdrData] = useState([])
  const [predictions, setPredictions] = useState(null)
  const [rcdStatus, setRcdStatus] = useState({
    sectorStatus: [],
    statusSummary: {
      totalRCDs: 0,
      activeRCDs: 0,
      faultedRCDs: 0,
      totalTripsToday: 0
    },
    recentEvents: []
  })
  const [error, setError] = useState(null)

  // Custom hooks
  const { alerts, unreadCount } = useAlerts()

  useEffect(() => {
    // Update time every second
    const timer = setInterval(() => setCurrentTime(new Date()), 1000)

    // Simulate connection status
    setTimeout(() => setConnectionStatus('CONNECTED'), 2000)

    return () => clearInterval(timer)
  }, [])

  useEffect(() => {
    const fetchData = async () => {
      try {
        setIsLoading(true)
        setError(null)
        
        const [realtimeRes, tdrRes, aiRes, rcdRes] = await Promise.all([
          fetch('/api/sas/realtime-data'),
          fetch('/api/sas/tdr-analysis'),
              fetch('/api/sas/ai-prediction?real=true'),
          fetch('/api/sas/rcd-status')
        ])

        if (!rcdRes.ok) {
          throw new Error(`RCD Status API failed: ${rcdRes.statusText}`)
        }

        const [realtimeData, tdrAnalysis, aiPredictions, rcdData] = await Promise.all([
          realtimeRes.json(),
          tdrRes.json(),
          aiRes.json(),
          rcdRes.json()
        ])
        
        // Enhance realtime data with additional metrics
        const enhancedRealtimeData = {
          ...realtimeData,
          recentIntrusions: [
            {
              location: "Wayanad Sector 3",
              timestamp: new Date(Date.now() - 1000 * 60 * 15).toISOString(),
              severity: "high"
            },
            {
              location: "Palakkad Sector 1",
              timestamp: new Date(Date.now() - 1000 * 60 * 45).toISOString(),
              severity: "medium"
            },
            {
              location: "Idukki Sector 7",
              timestamp: new Date(Date.now() - 1000 * 60 * 120).toISOString(),
              severity: "low"
            }
          ],
          powerMetrics: Array(24).fill(0).map((_, i) => ({
            time: `${i}:00`,
            voltage: 220 + Math.random() * 20,
            current: 150 + Math.random() * 50
          }))
        }
        
        setData(enhancedRealtimeData)
        setTdrData(tdrAnalysis)
        setPredictions(aiPredictions)
        
        if (rcdData && typeof rcdData === 'object') {
          setRcdStatus({
            sectorStatus: Array.isArray(rcdData.sectorStatus) ? rcdData.sectorStatus : [],
            statusSummary: rcdData.statusSummary || {
              totalRCDs: 0,
              activeRCDs: 0,
              faultedRCDs: 0,
              totalTripsToday: 0
            },
            recentEvents: Array.isArray(rcdData.recentEvents) ? rcdData.recentEvents : []
          })
        }
        
        setAlertCount(realtimeData.alerts?.length || 0)
        setIsLoading(false)
      } catch (error) {
        console.error('Error fetching data:', error)
        setIsLoading(false)
      }
    }

        fetchData()
        const interval = setInterval(fetchData, 30000) // Update every 30 seconds
        return () => clearInterval(interval)
      }, []) // Re-fetch data periodically

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-green-100 text-foreground">
      <Head>
        <title key="title">SAS Electric Fence Detection</title>
        <meta key="description" name="description" content="Advanced Substation Automation System for Electric Fence Detection" />
      </Head>

      {/* Header */}
      <header className="sticky top-0 z-50 w-full border-b border-green-200/60 backdrop-blur-md bg-white/80 shadow-sm">
        <div className="container flex h-16 items-center justify-between max-w-[1920px] mx-auto px-4">
          <div className="flex gap-6 md:gap-10">
            <div className="flex items-center space-x-3 animate-fade-in">
              <div className="relative">
                <Zap className="h-7 w-7 text-green-600 animate-pulse-glow" />
                <div className="absolute inset-0 bg-green-400 rounded-full blur-sm opacity-30 animate-pulse-slow"></div>
              </div>
              <span className="font-bold text-xl bg-gradient-to-r from-green-700 to-green-600 bg-clip-text text-transparent">
                SAS Electric Fence
              </span>
            </div>
            <nav className="hidden md:flex gap-2">
              <Button 
                variant={activeTab === 'overview' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'overview' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('overview')}
              >
                <Activity className="h-4 w-4" /> Overview
              </Button>
              <Button 
                variant={activeTab === 'tdr' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'tdr' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('tdr')}
              >
                <LineChart className="h-4 w-4" /> TDR Analysis
              </Button>
              <Button 
                variant={activeTab === 'ai' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'ai' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('ai')}
              >
                <Brain className="h-4 w-4" /> AI Predictions
              </Button>
              <Button 
                variant={activeTab === 'rcd' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'rcd' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('rcd')}
              >
                <Shield className="h-4 w-4" /> RCD Monitoring
              </Button>
              <Button 
                variant={activeTab === 'map' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'map' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('map')}
              >
                <MapPin className="h-4 w-4" /> Geospatial
              </Button>
              <Button 
                variant={activeTab === 'export' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'export' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('export')}
              >
                <Download className="h-4 w-4" /> Export
              </Button>
              <Button 
                variant={activeTab === 'sms' ? 'secondary' : 'ghost'} 
                className={`flex items-center gap-2 nav-button transition-all duration-300 ${
                  activeTab === 'sms' ? 'active bg-green-100 text-green-700' : 'hover:bg-green-50'
                }`}
                onClick={() => setActiveTab('sms')}
              >
                <Bell className="h-4 w-4" /> SMS Alerts
              </Button>
            </nav>
          </div>
              <div className="flex items-center gap-4">
                <NotificationsMenu alertCount={alertCount} />
                <SettingsMenu />
              </div>
        </div>
      </header>


      {/* Main Content */}
      <main className="py-12 min-h-[calc(100vh-4rem)] bg-gray-50">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="mx-auto max-w-[1920px] px-4 space-y-8 page-transition">
          <div className="flex items-center justify-end animate-fade-in-down">
            <div className="flex items-center space-x-3">
              <Badge 
                variant={connectionStatus === 'CONNECTED' ? 'success' : 'destructive'} 
                className={`h-8 px-3 py-1 text-sm font-medium transition-all duration-300 ${
                  connectionStatus === 'CONNECTED' 
                    ? 'bg-green-100 text-green-700 border-green-200 animate-pulse-glow' 
                    : 'bg-red-100 text-red-700 border-red-200'
                }`}
              >
                <Wifi className="h-3 w-3 mr-2" />
                {connectionStatus}
              </Badge>
              <Badge variant="outline" className="h-8 px-3 py-1 text-sm font-medium bg-white/80 border-green-200 text-green-700">
                <Clock className="h-3 w-3 mr-2" />
                <span suppressHydrationWarning>{currentTime.toLocaleTimeString()}</span>
              </Badge>
            </div>
          </div>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-8 tab-transition">
            {/* Hero Section - Only on Overview */}
            <section className="relative h-[80vh] min-h-[600px] overflow-hidden rounded-2xl mb-12">
              <div className="absolute inset-0 bg-gradient-to-br from-emerald-900/90 via-teal-800/85 to-green-700/80">
                <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80')] bg-cover bg-center bg-no-repeat"></div>
                <div className="absolute inset-0 bg-gradient-to-r from-emerald-900/60 via-transparent to-teal-800/40"></div>
              </div>
              
              {/* Floating UI Elements */}
              <div className="absolute top-20 right-20 w-32 h-32 bg-gradient-to-br from-emerald-400/30 to-teal-500/20 rounded-full animate-float animate-morphing"></div>
              <div className="absolute top-40 left-20 w-20 h-20 bg-gradient-to-br from-teal-400/40 to-green-500/30 rounded-full animate-float animate-stagger-1 animate-glow"></div>
              <div className="absolute bottom-32 right-32 w-16 h-16 bg-gradient-to-br from-green-400/35 to-emerald-500/25 rounded-full animate-float animate-stagger-2 animate-particle-float"></div>
              <div className="absolute bottom-20 left-40 w-24 h-24 bg-gradient-to-br from-emerald-300/30 to-teal-400/20 rounded-full animate-float animate-stagger-3 animate-morphing"></div>
              
              {/* Additional Floating Particles */}
              <div className="absolute top-60 right-40 w-8 h-8 bg-teal-300/40 rounded-full animate-particle-float animate-stagger-1"></div>
              <div className="absolute top-80 left-60 w-6 h-6 bg-emerald-300/50 rounded-full animate-particle-float animate-stagger-2"></div>
              <div className="absolute bottom-60 right-60 w-10 h-10 bg-green-300/30 rounded-full animate-particle-float animate-stagger-3"></div>
              <div className="absolute bottom-80 left-80 w-12 h-12 bg-teal-300/25 rounded-full animate-particle-float animate-stagger-4"></div>
              
              {/* Animated Grid Pattern */}
              <div className="absolute inset-0 opacity-10">
                <div className="grid grid-cols-12 h-full">
                  {Array.from({ length: 144 }).map((_, i) => (
                    <div key={i} className="border border-emerald-300/20 animate-pulse" style={{ animationDelay: `${i * 0.01}s` }}></div>
                  ))}
                </div>
              </div>
              
              <div className="relative z-10 h-full flex items-center">
                <div className="container mx-auto px-4 max-w-7xl">
                  <div className="max-w-5xl">
                    <div className="mb-8 animate-fade-in-up">
                      <div className="inline-flex items-center px-4 py-2 bg-emerald-500/20 backdrop-blur-sm rounded-full border border-emerald-400/30 mb-6">
                        <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse-glow mr-3"></div>
                        <span className="text-emerald-200 font-medium">Live System Status</span>
                      </div>
                    </div>
                    
                    <h1 className="text-6xl md:text-8xl font-black text-white mb-8 leading-tight animate-fade-in-up animate-stagger-1">
                      <span className="block bg-gradient-to-r from-white via-emerald-100 to-teal-200 bg-clip-text text-transparent">
                        Advanced Electric
                      </span>
                      <span className="block bg-gradient-to-r from-emerald-300 via-green-400 to-teal-300 bg-clip-text text-transparent">
                        Fence Detection
                      </span>
                    </h1>
                    
                    <p className="text-2xl md:text-3xl text-emerald-100 mb-12 leading-relaxed max-w-4xl animate-fade-in-up animate-stagger-2">
                      Real-time monitoring and AI-powered analysis for Kerala's power infrastructure
                    </p>
                    
                    {/* Interactive Stats Cards */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 animate-fade-in-up animate-stagger-3">
                      <div className="group bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 hover:bg-white/15 transition-all duration-500 hover:scale-105 hover:shadow-2xl hover:shadow-emerald-500/20 relative overflow-hidden">
                        <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 to-teal-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                        <div className="relative z-10">
                          <div className="flex items-center justify-between mb-4">
                            <div className="w-12 h-12 bg-gradient-to-br from-emerald-500/30 to-teal-500/20 rounded-xl flex items-center justify-center group-hover:animate-wiggle">
                              <Zap className="w-6 h-6 text-emerald-300" />
                            </div>
                            <div className="text-right">
                              <div className="text-3xl font-bold text-white group-hover:animate-pulse-glow">245.8</div>
                              <div className="text-emerald-200 text-sm">km Fence</div>
                            </div>
                          </div>
                          <div className="w-full bg-white/20 rounded-full h-2 overflow-hidden">
                            <div className="bg-gradient-to-r from-emerald-400 via-teal-400 to-green-400 h-2 rounded-full animate-gradient-shift" style={{width: '100%'}}></div>
                          </div>
                        </div>
                      </div>
                      
                      <div className="group bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 hover:bg-white/15 transition-all duration-500 hover:scale-105 hover:shadow-2xl hover:shadow-teal-500/20 relative overflow-hidden">
                        <div className="absolute inset-0 bg-gradient-to-br from-teal-500/5 to-green-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                        <div className="relative z-10">
                          <div className="flex items-center justify-between mb-4">
                            <div className="w-12 h-12 bg-gradient-to-br from-teal-500/30 to-green-500/20 rounded-xl flex items-center justify-center group-hover:animate-wiggle">
                              <Activity className="w-6 h-6 text-teal-300" />
                            </div>
                            <div className="text-right">
                              <div className="text-3xl font-bold text-white group-hover:animate-pulse-glow">98.2%</div>
                              <div className="text-emerald-200 text-sm">Active</div>
                            </div>
                          </div>
                          <div className="w-full bg-white/20 rounded-full h-2 overflow-hidden">
                            <div className="bg-gradient-to-r from-teal-400 via-green-400 to-emerald-400 h-2 rounded-full animate-gradient-shift" style={{width: '98.2%'}}></div>
                          </div>
                        </div>
                      </div>
                      
                      <div className="group bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 hover:bg-white/15 transition-all duration-500 hover:scale-105 hover:shadow-2xl hover:shadow-green-500/20 relative overflow-hidden">
                        <div className="absolute inset-0 bg-gradient-to-br from-green-500/5 to-emerald-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                        <div className="relative z-10">
                          <div className="flex items-center justify-between mb-4">
                            <div className="w-12 h-12 bg-gradient-to-br from-green-500/30 to-emerald-500/20 rounded-xl flex items-center justify-center group-hover:animate-wiggle">
                              <Shield className="w-6 h-6 text-green-300" />
                            </div>
                            <div className="text-right">
                              <div className="text-3xl font-bold text-white group-hover:animate-pulse-glow">24/7</div>
                              <div className="text-emerald-200 text-sm">Monitoring</div>
                            </div>
                          </div>
                          <div className="w-full bg-white/20 rounded-full h-2 overflow-hidden">
                            <div className="bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400 h-2 rounded-full animate-gradient-shift" style={{width: '100%'}}></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              
              {/* Animated Bottom Gradient */}
              <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-gray-50 via-gray-50/80 to-transparent"></div>
            </section>

            {/* System Overview Section */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
              <div className="lg:col-span-2">
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
              <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-2xl">Substation Single Line Diagram</CardTitle>
                    <CardDescription className="text-green-600 text-lg">Real-time status of major substations and their interconnections</CardDescription>
              </CardHeader>
              <CardContent className="p-0">
                <SingleLineDiagram />
              </CardContent>
            </Card>
              </div>
              <div className="space-y-6">
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                  <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">System Status</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="space-y-4">
                      <div className="flex items-center justify-between p-4 bg-green-50 rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse-glow"></div>
                          <span className="font-medium text-green-800">System Online</span>
                        </div>
                        <Badge className="bg-green-100 text-green-700">Active</Badge>
                      </div>
                      <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
                          <span className="font-medium text-blue-800">Data Sync</span>
                        </div>
                        <Badge className="bg-blue-100 text-blue-700">Real-time</Badge>
                      </div>
                      <div className="flex items-center justify-between p-4 bg-yellow-50 rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
                          <span className="font-medium text-yellow-800">Maintenance</span>
                        </div>
                        <Badge className="bg-yellow-100 text-yellow-700">Scheduled</Badge>
                      </div>
                    </div>
                </CardContent>
              </Card>
                
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                  <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">Quick Actions</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="space-y-3">
                      <Button className="w-full justify-start bg-green-600 hover:bg-green-700 text-white">
                        <Settings className="mr-2 h-4 w-4" />
                        System Settings
                      </Button>
                      <Button variant="outline" className="w-full justify-start border-green-200 text-green-700 hover:bg-green-50">
                        <Download className="mr-2 h-4 w-4" />
                        Export Data
                      </Button>
                      <Button variant="outline" className="w-full justify-start border-green-200 text-green-700 hover:bg-green-50">
                        <Bell className="mr-2 h-4 w-4" />
                        Alert Settings
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
            {/* Key Metrics Section */}
            <div className="mb-12">
              <h2 className="text-3xl font-bold text-green-800 mb-8 text-center">System Performance Metrics</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg animate-fade-in-up group relative overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-br from-green-50 to-green-100 opacity-50"></div>
                  <CardHeader className="pb-2 relative z-10">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-sm font-medium text-green-600">Total Fence Length</CardTitle>
                      <MapPin className="h-5 w-5 text-green-500" />
                    </div>
                  </CardHeader>
                  <CardContent className="relative z-10">
                    <div className="text-4xl font-bold text-green-700 mb-2">245.8 km</div>
                    <p className="text-sm text-green-600 font-medium">Across Kerala State</p>
                    <div className="mt-3 w-full bg-green-200 rounded-full h-2">
                      <div className="bg-green-500 h-2 rounded-full" style={{width: '100%'}}></div>
                    </div>
                  </CardContent>
                </Card>
                
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg animate-fade-in-up animate-stagger-1 group relative overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-br from-green-50 to-green-100 opacity-50"></div>
                  <CardHeader className="pb-2 relative z-10">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-sm font-medium text-green-600">Active Monitoring</CardTitle>
                      <Activity className="h-5 w-5 text-green-500 animate-pulse" />
                    </div>
                  </CardHeader>
                  <CardContent className="relative z-10">
                    <div className="text-4xl font-bold text-green-600 animate-pulse-glow mb-2">98.2%</div>
                    <p className="text-sm text-green-600 font-medium">241.3 km monitored</p>
                    <div className="mt-3 w-full bg-green-200 rounded-full h-2">
                      <div className="bg-green-500 h-2 rounded-full animate-pulse" style={{width: '98.2%'}}></div>
                    </div>
                </CardContent>
              </Card>
                
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-red-200/50 shadow-lg animate-fade-in-up animate-stagger-2 group relative overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-br from-red-50 to-red-100 opacity-50"></div>
                  <CardHeader className="pb-2 relative z-10">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-sm font-medium text-red-600">Fence Breaches</CardTitle>
                      <AlertTriangle className="h-5 w-5 text-red-500" />
                    </div>
                </CardHeader>
                  <CardContent className="relative z-10">
                    <div className="text-4xl font-bold text-red-600 mb-2">24</div>
                    <p className="text-sm text-red-600 font-medium">Last 24 hours</p>
                    <div className="mt-3 w-full bg-red-200 rounded-full h-2">
                      <div className="bg-red-500 h-2 rounded-full" style={{width: '60%'}}></div>
                    </div>
                </CardContent>
              </Card>
                
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-blue-200/50 shadow-lg animate-fade-in-up animate-stagger-3 group relative overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-50 to-blue-100 opacity-50"></div>
                  <CardHeader className="pb-2 relative z-10">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-sm font-medium text-blue-600">Power Consumption</CardTitle>
                      <Zap className="h-5 w-5 text-blue-500" />
                    </div>
                </CardHeader>
                  <CardContent className="relative z-10">
                    <div className="text-4xl font-bold text-blue-600 mb-2">4.2 MW</div>
                    <p className="text-sm text-blue-600 font-medium">Current draw</p>
                    <div className="mt-3 w-full bg-blue-200 rounded-full h-2">
                      <div className="bg-blue-500 h-2 rounded-full" style={{width: '75%'}}></div>
                    </div>
                </CardContent>
              </Card>
              </div>
            </div>

            {/* Monitoring Dashboard Section */}
            <div className="mb-12">
              <h2 className="text-3xl font-bold text-green-800 mb-8 text-center">Real-time Monitoring Dashboard</h2>
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Alerts Summary */}
                <Card className="lg:col-span-2 hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">Recent Intrusion Attempts</CardTitle>
                    <CardDescription className="text-green-600">Live security monitoring across all sectors</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {data?.recentIntrusions?.map((intrusion, i) => (
                        <div key={i} className="flex items-center justify-between p-4 border border-green-200/30 rounded-lg bg-green-50/50 hover:bg-green-100/50 transition-all duration-300 hover:shadow-md animate-fade-in-up" style={{ animationDelay: `${i * 0.1}s` }}>
                        <div className="space-y-1">
                            <p className="font-semibold text-green-800 text-lg">{intrusion.location}</p>
                            <div className="flex items-center text-sm text-green-600">
                              <Clock className="w-4 h-4 mr-2" />
                            {new Date(intrusion.timestamp).toLocaleString()}
                          </div>
                        </div>
                          <Badge className={`px-4 py-2 text-sm font-semibold ${
                            intrusion.severity === 'high' ? 'bg-red-100 text-red-700 border-red-200' : 
                            intrusion.severity === 'medium' ? 'bg-yellow-100 text-yellow-700 border-yellow-200' : 
                            'bg-green-100 text-green-700 border-green-200'
                          }`}>
                          {intrusion.severity.toUpperCase()}
                        </Badge>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* System Health */}
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">System Health</CardTitle>
                    <CardDescription className="text-green-600">Overall system status</CardDescription>
                </CardHeader>
                <CardContent>
                  <SystemHealth />
                </CardContent>
              </Card>
              </div>
            </div>

            {/* Charts Section */}
            <div className="mb-12">
              <h2 className="text-3xl font-bold text-green-800 mb-8 text-center">Analytics & Performance</h2>
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Real-time Power Metrics */}
                <Card className="lg:col-span-2 hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg chart-container">
                <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">Power Distribution</CardTitle>
                    <CardDescription className="text-green-600">Real-time voltage and current monitoring</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="h-[400px]">
                    <ResponsiveContainer width="100%" height="100%">
                        <RechartsLineChart data={data?.powerMetrics || [
                          { time: "00:00", voltage: 220, current: 150 },
                          { time: "04:00", voltage: 225, current: 155 },
                          { time: "08:00", voltage: 230, current: 160 },
                          { time: "12:00", voltage: 235, current: 165 },
                          { time: "16:00", voltage: 240, current: 170 },
                          { time: "20:00", voltage: 238, current: 168 }
                        ]}>
                          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                          <XAxis dataKey="time" stroke="#6b7280" />
                          <YAxis stroke="#6b7280" />
                          <Tooltip 
                            contentStyle={{
                              backgroundColor: 'rgba(255, 255, 255, 0.95)',
                              border: '1px solid #22c55e',
                              borderRadius: '8px',
                              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                            }}
                          />
                        <Legend />
                          <Line type="monotone" dataKey="voltage" stroke="#3b82f6" strokeWidth={3} name="Voltage (kV)" />
                          <Line type="monotone" dataKey="current" stroke="#22c55e" strokeWidth={3} name="Current (A)" />
                      </RechartsLineChart>
                    </ResponsiveContainer>
                  </div>
                </CardContent>
              </Card>

              {/* Recent Alerts */}
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">Alerts Summary</CardTitle>
                    <CardDescription className="text-green-600">System notifications</CardDescription>
                </CardHeader>
                <CardContent>
                  <AlertsPanel />
                </CardContent>
              </Card>
              </div>
            </div>

            {/* Regional Analysis Section */}
            <div className="mb-12">
              <h2 className="text-3xl font-bold text-green-800 mb-8 text-center">Regional Analysis & Environmental Factors</h2>
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">Fence Status by Region</CardTitle>
                    <CardDescription className="text-green-600">Operational status across Kerala districts</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-6">
                      {[
                        { region: 'North Kerala', status: 'Operational', health: 98, image: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80' },
                        { region: 'Central Kerala', status: 'Warning', health: 85, image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80' },
                        { region: 'South Kerala', status: 'Critical', health: 72, image: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80' },
                    ].map((region, i) => (
                        <div key={i} className="flex items-center space-x-4 p-4 border border-green-200/30 rounded-lg bg-green-50/50 hover:bg-green-100/50 transition-all duration-300 animate-fade-in-up" style={{ animationDelay: `${i * 0.1}s` }}>
                          <div className="w-16 h-16 rounded-lg overflow-hidden flex-shrink-0">
                            <img src={region.image} alt={region.region} className="w-full h-full object-cover" />
                          </div>
                          <div className="flex-1 space-y-3">
                            <div className="flex justify-between items-center">
                              <span className="font-semibold text-green-800 text-lg">{region.region}</span>
                              <span className={`font-semibold px-3 py-1 rounded-full text-sm ${
                                region.health > 90 ? 'bg-green-100 text-green-700' :
                                region.health > 80 ? 'bg-yellow-100 text-yellow-700' :
                                'bg-red-100 text-red-700'
                              }`}>{region.status}</span>
                            </div>
                            <div className="relative">
                              <Progress 
                                value={region.health} 
                                className={`h-3 ${
                                  region.health > 90 ? '[&>div]:bg-green-500' :
                                  region.health > 80 ? '[&>div]:bg-yellow-500' :
                                  '[&>div]:bg-red-500'
                                }`} 
                              />
                              <div className="absolute inset-0 flex items-center justify-center text-xs font-medium text-white">
                                {region.health}%
                              </div>
                            </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

                <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                <CardHeader>
                    <CardTitle className="text-green-800 font-semibold text-xl">Weather Impact Analysis</CardTitle>
                    <CardDescription className="text-green-600">Environmental factors affecting system performance</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                        { condition: 'Heavy Rain', risk: 'High', areas: 'Wayanad, Idukki', icon: '🌧️' },
                        { condition: 'Lightning', risk: 'Medium', areas: 'Palakkad', icon: '⚡' },
                        { condition: 'Strong Winds', risk: 'Low', areas: 'Coastal Regions', icon: '💨' },
                    ].map((weather, i) => (
                        <div key={i} className="flex items-center justify-between p-4 border border-green-200/30 rounded-lg bg-green-50/50 hover:bg-green-100/50 transition-all duration-300 animate-fade-in-up" style={{ animationDelay: `${i * 0.1}s` }}>
                          <div className="flex items-center space-x-3">
                            <span className="text-2xl">{weather.icon}</span>
                        <div className="space-y-1">
                              <p className="font-semibold text-green-800 text-lg">{weather.condition}</p>
                              <p className="text-sm text-green-600">{weather.areas}</p>
                            </div>
                        </div>
                          <Badge className={`px-4 py-2 text-sm font-semibold ${
                            weather.risk === 'High' ? 'bg-red-100 text-red-700 border-red-200' :
                            weather.risk === 'Medium' ? 'bg-yellow-100 text-yellow-700 border-yellow-200' :
                            'bg-green-100 text-green-700 border-green-200'
                          }`}>{weather.risk}</Badge>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
              </div>
            </div>
          </TabsContent>

          {/* TDR Analysis Tab */}
          <TabsContent value="tdr" className="space-y-6 tab-transition">
            <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
              <CardHeader>
                <CardTitle className="text-green-800 font-semibold text-xl">Time Domain Reflectometry Analysis</CardTitle>
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <div className="flex items-center justify-center h-96">
                    <div className="flex flex-col items-center space-y-4">
                      <div className="animate-spin rounded-full h-12 w-12 border-4 border-green-200 border-t-green-600"></div>
                      <p className="text-green-600 font-medium">Loading TDR Analysis...</p>
                    </div>
                  </div>
                ) : error ? (
                  <div className="p-6 border border-red-200 bg-red-50 rounded-lg">
                    <div className="flex items-center space-x-2">
                      <AlertTriangle className="h-5 w-5 text-red-600" />
                      <p className="text-sm text-red-700 font-medium">{error}</p>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-6">
                    <div className="h-96 chart-container">
                      <ResponsiveContainer width="100%" height="100%">
                        <RechartsLineChart data={tdrData?.reflectionData || []}>
                          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                          <XAxis dataKey="distance" label={{ value: "Distance (m)", position: "insideBottom", offset: -5 }} stroke="#6b7280" />
                          <YAxis label={{ value: "Reflection (dB)", angle: -90, position: "insideLeft", offset: 10 }} stroke="#6b7280" />
                          <Tooltip 
                            contentStyle={{
                              backgroundColor: 'rgba(255, 255, 255, 0.95)',
                              border: '1px solid #22c55e',
                              borderRadius: '8px',
                              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                            }}
                          />
                          <Legend />
                          <Line type="monotone" dataKey="reflection" stroke="#3b82f6" strokeWidth={3} name="TDR Signal" />
                          <Line type="monotone" dataKey="impedance" stroke="#22c55e" strokeWidth={3} name="Impedance" />
                        </RechartsLineChart>
                      </ResponsiveContainer>
                    </div>
                    {tdrData?.detectedAnomalies && tdrData.detectedAnomalies.length > 0 && (
                      <div className="space-y-6">
                        <h3 className="font-semibold text-xl text-green-800">Detected Anomalies</h3>
                        <div className="grid gap-4">
                          {tdrData.detectedAnomalies.map((anomaly, index) => (
                            <div key={`${anomaly.anomalyType}-${anomaly.distance}-${index}`} className="p-6 border border-green-200/50 rounded-lg bg-green-50/50 hover:bg-green-100/50 transition-all duration-300 hover:shadow-md animate-fade-in-up" style={{ animationDelay: `${index * 0.1}s` }}>
                              <div className="flex items-center justify-between mb-4">
                                <span className="font-semibold text-green-800 text-lg">{anomaly.anomalyType.replace(/_/g, ' ')}</span>
                                <Badge className={`px-3 py-1 text-sm font-medium ${
                                  anomaly.severity === 'CRITICAL' ? 'bg-red-100 text-red-700 border-red-200' : 
                                  'bg-yellow-100 text-yellow-700 border-yellow-200'
                                }`}>
                                  {anomaly.severity}
                                </Badge>
                              </div>
                              <div className="grid gap-3 text-sm">
                                <div className="flex justify-between items-center p-2 bg-white/50 rounded">
                                  <span className="text-green-600 font-medium">Distance:</span>
                                  <span className="font-semibold text-green-800">{anomaly.distance}m</span>
                                </div>
                                <div className="flex justify-between items-center p-2 bg-white/50 rounded">
                                  <span className="text-green-600 font-medium">Confidence:</span>
                                  <span className="font-semibold text-green-800">{anomaly.confidence.toFixed(1)}%</span>
                                </div>
                                <div className="flex justify-between items-center p-2 bg-white/50 rounded">
                                  <span className="text-green-600 font-medium">Action:</span>
                                  <span className="text-right font-semibold text-green-800">{anomaly.recommendedAction.replace(/_/g, ' ')}</span>
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* AI Predictions Tab */}
          <TabsContent value="ai" className="space-y-6 tab-transition">
            <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-green-800 font-semibold text-xl">
                        Trained Fence Detection
                      </CardTitle>
                      <Badge className="bg-green-600 text-white px-3 py-1">
                        <Brain className="h-3 w-3 mr-1" />
                        Trained Model Active
                      </Badge>
                    </div>
                    <div className="text-sm text-green-700 bg-green-50 p-3 rounded-lg border border-green-200">
                      <strong>🤖 Live TDR Data:</strong> Using real TDR measurements from CSV dataset with your trained fence detection model. 
                      {predictions?.trainedModelIntegration?.datasetStats && (
                        <span className="block mt-1 text-xs">
                          Dataset: {predictions.trainedModelIntegration.datasetStats.totalMeasurements} measurements, 
                          {predictions.trainedModelIntegration.datasetStats.fenceDetections} fence detections ({predictions.trainedModelIntegration.datasetStats.fencePercentage}%)
                        </span>
                      )}
                    </div>
                  </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="h-80 chart-container">
                    <ResponsiveContainer width="100%" height="100%">
                      <BarChart data={predictions?.predictions || []}>
                        <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                        <XAxis dataKey="futureHour" label={{ value: 'Hour', position: 'insideBottom', offset: -5 }} stroke="#6b7280" />
                        <YAxis label={{ value: 'Predicted Values', angle: -90, position: 'insideLeft', offset: 10 }} stroke="#6b7280" />
                        <Tooltip 
                          contentStyle={{
                            backgroundColor: 'rgba(255, 255, 255, 0.95)',
                            border: '1px solid #22c55e',
                            borderRadius: '8px',
                            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                          }}
                        />
                        <Legend />
                        <Bar dataKey="predictedVoltage" fill="#3b82f6" name="Voltage (V)" radius={[4, 4, 0, 0]} />
                        <Bar dataKey="predictedCurrent" fill="#22c55e" name="Current (A)" radius={[4, 4, 0, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  </div>
                  <div className="space-y-4">
                    {predictions?.summary?.recommendations?.map((rec, index) => (
                      <div key={`recommendation-${index}-${rec.slice(0, 20)}`} className="p-6 bg-green-50/50 border border-green-200/50 rounded-lg hover:bg-green-100/50 transition-all duration-300 hover:shadow-md animate-fade-in-up" style={{ animationDelay: `${index * 0.1}s` }}>
                        <h4 className="font-semibold mb-3 text-green-800 text-lg">AI Recommendation {index + 1}</h4>
                        <p className="text-sm text-green-700 leading-relaxed">{rec}</p>
                      </div>
                    ))}
                        {predictions?.modelMetrics && (
                          <div className="mt-6 p-6 bg-green-50/50 border border-green-200/50 rounded-lg animate-fade-in-up">
                            <h4 className="font-semibold mb-4 text-green-800 text-lg">
                              Trained Model Performance
                            </h4>
                            <div className="grid grid-cols-2 gap-4 text-sm">
                              <div className="flex justify-between items-center p-3 bg-white/50 rounded">
                                <span className="text-green-600 font-medium">Accuracy:</span>
                                <span className="font-semibold text-green-800">{predictions.modelMetrics.accuracy.toFixed(1)}%</span>
                              </div>
                              <div className="flex justify-between items-center p-3 bg-white/50 rounded">
                                <span className="text-green-600 font-medium">Precision:</span>
                                <span className="font-semibold text-green-800">{predictions.modelMetrics.precision.toFixed(1)}%</span>
                              </div>
                              <div className="flex justify-between items-center p-3 bg-white/50 rounded">
                                <span className="text-green-600 font-medium">Model Type:</span>
                                <span className="font-semibold text-green-800">{predictions.modelMetrics.modelType}</span>
                              </div>
                              <div className="flex justify-between items-center p-3 bg-white/50 rounded">
                                <span className="text-green-600 font-medium">Version:</span>
                                <span className="font-semibold text-green-800">{predictions.modelMetrics.modelVersion}</span>
                              </div>
                            </div>
                            {predictions?.trainedModelIntegration && (
                              <div className="mt-4 p-4 bg-green-100/50 border border-green-300/50 rounded-lg">
                                <h5 className="font-semibold mb-2 text-green-800">Trained Model Integration Status</h5>
                                <div className="grid grid-cols-2 gap-2 text-xs">
                                  <div className="flex justify-between">
                                    <span className="text-green-600">Status:</span>
                                    <span className="font-semibold text-green-800">{predictions.trainedModelIntegration.status}</span>
                                  </div>
                                  <div className="flex justify-between">
                                    <span className="text-green-600">Inferences:</span>
                                    <span className="font-semibold text-green-800">{predictions.trainedModelIntegration.totalInferences}</span>
                                  </div>
                                </div>
                              </div>
                            )}
                          </div>
                        )}
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* RCD Monitoring Tab */}
          <TabsContent value="rcd" className="space-y-6 tab-transition">
            <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
              <CardHeader>
                <CardTitle className="text-green-800 font-semibold text-xl">Residual Current Device Monitoring</CardTitle>
              </CardHeader>
              <CardContent>
                {error ? (
                  <div className="p-6 border border-red-200 bg-red-50 rounded-lg">
                    <div className="flex items-center space-x-2">
                      <AlertTriangle className="h-5 w-5 text-red-600" />
                      <p className="text-sm text-red-700 font-medium">{error}</p>
                    </div>
                  </div>
                ) : isLoading ? (
                  <div className="flex items-center justify-center h-40">
                    <div className="flex flex-col items-center space-y-4">
                      <div className="animate-spin rounded-full h-12 w-12 border-4 border-green-200 border-t-green-600"></div>
                      <p className="text-green-600 font-medium">Loading RCD Status...</p>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-6">
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
                      <Card className="col-span-1 hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg animate-fade-in-up">
                        <CardHeader className="pb-2">
                          <CardTitle className="text-sm text-green-600 font-medium">Total RCDs</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <div className="text-3xl font-bold text-green-700">{rcdStatus?.statusSummary?.totalRCDs || 0}</div>
                        </CardContent>
                      </Card>
                      <Card className="col-span-1 hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg animate-fade-in-up animate-stagger-1">
                        <CardHeader className="pb-2">
                          <CardTitle className="text-sm text-green-600 font-medium">Active RCDs</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <div className="text-3xl font-bold text-green-600 animate-pulse-glow">{rcdStatus?.statusSummary?.activeRCDs || 0}</div>
                        </CardContent>
                      </Card>
                      <Card className="col-span-1 hover-card bg-white/90 backdrop-blur-sm border-red-200/50 shadow-lg animate-fade-in-up animate-stagger-2">
                        <CardHeader className="pb-2">
                          <CardTitle className="text-sm text-red-600 font-medium">Faulted RCDs</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <div className="text-3xl font-bold text-red-600">{rcdStatus?.statusSummary?.faultedRCDs || 0}</div>
                        </CardContent>
                      </Card>
                      <Card className="col-span-1 hover-card bg-white/90 backdrop-blur-sm border-yellow-200/50 shadow-lg animate-fade-in-up animate-stagger-3">
                        <CardHeader className="pb-2">
                          <CardTitle className="text-sm text-yellow-600 font-medium">Trips Today</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <div className="text-3xl font-bold text-yellow-600">{rcdStatus?.statusSummary?.totalTripsToday || 0}</div>
                        </CardContent>
                      </Card>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                      {rcdStatus?.sectorStatus?.map((sector, index) => (
                        <div key={sector.sectorId} className="p-6 bg-green-50/50 border border-green-200/50 rounded-lg hover:bg-green-100/50 transition-all duration-300 hover:shadow-md animate-fade-in-up" style={{ animationDelay: `${index * 0.1}s` }}>
                          <div className="flex justify-between items-start mb-4">
                            <h3 className="font-semibold text-green-800 text-lg">{sector.sectorId}</h3>
                            <Badge className={`px-3 py-1 text-sm font-medium ${
                              sector.rcdsActive === sector.rcdsInstalled 
                                ? 'bg-green-100 text-green-700 border-green-200' 
                                : 'bg-red-100 text-red-700 border-red-200'
                            }`}>
                              {sector.rcdsActive}/{sector.rcdsInstalled} Active
                            </Badge>
                          </div>
                          <div className="space-y-4">
                            <div className="flex justify-between items-center p-3 bg-white/50 rounded">
                              <span className="text-green-600 font-medium">Average Leakage:</span>
                              <span className="font-semibold text-green-800">{sector.averageLeakage}mA</span>
                            </div>
                            <div className="relative">
                              <Progress 
                                value={(sector.averageLeakage / 30) * 100} 
                                className="h-3 [&>div]:bg-green-500" 
                              />
                              <div className="absolute inset-0 flex items-center justify-center text-xs font-medium text-white">
                                {Math.round((sector.averageLeakage / 30) * 100)}%
                              </div>
                            </div>
                            <div className="flex justify-between items-center p-3 bg-white/50 rounded">
                              <span className="text-green-600 font-medium">Last Trip:</span>
                              <span className="font-semibold text-green-800 text-xs">{sector.lastTrip ? new Date(sector.lastTrip).toLocaleString() : 'N/A'}</span>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Geospatial Map Tab */}
          <TabsContent value="map" className="space-y-6 tab-transition">
            <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
              <CardHeader>
                <CardTitle className="text-green-800 font-semibold text-xl">Kerala Power Grid - Geospatial View</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="h-[600px] rounded-lg overflow-hidden border border-green-200/50 shadow-inner">
                  <MapWrapper />
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Data Export Tab */}
          <TabsContent value="export" className="space-y-6 tab-transition">
            <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
              <CardHeader>
                <CardTitle className="text-green-800 font-semibold text-xl">Historical Data Export</CardTitle>
              </CardHeader>
              <CardContent>
                <DataExport />
              </CardContent>
            </Card>
          </TabsContent>

          {/* SMS Management Tab */}
          <TabsContent value="sms" className="space-y-6 tab-transition">
            <Card className="hover-card bg-white/90 backdrop-blur-sm border-green-200/50 shadow-lg">
              <CardHeader>
                <CardTitle className="text-green-800 font-semibold text-xl">SMS Alert Management</CardTitle>
                <CardDescription>
                  Configure and test SMS notifications for open circuit detection and system alerts
                </CardDescription>
              </CardHeader>
              <CardContent>
                <SMSManager />
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </main>

      {/* Footer */}
      <footer className="bg-green-900 text-white py-12">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="md:col-span-2">
              <div className="flex items-center space-x-3 mb-4">
                <Zap className="h-8 w-8 text-green-300" />
                <span className="text-2xl font-bold">SAS Electric Fence</span>
              </div>
              <p className="text-green-200 mb-6 max-w-md">
                Advanced Substation Automation System for Electric Fence Detection with IEC 61850 Integration. 
                Real-time monitoring and AI-powered analysis for Kerala's power infrastructure.
              </p>
              <div className="flex space-x-4">
                <Button variant="outline" className="border-green-300 text-green-300 hover:bg-green-300 hover:text-green-900">
                  <Download className="mr-2 h-4 w-4" />
                  Download App
                </Button>
                <Button variant="outline" className="border-green-300 text-green-300 hover:bg-green-300 hover:text-green-900">
                  <Settings className="mr-2 h-4 w-4" />
                  Documentation
                </Button>
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold mb-4">Quick Links</h3>
              <ul className="space-y-2">
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">Dashboard</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">TDR Analysis</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">AI Predictions</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">RCD Monitoring</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">Geospatial View</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold mb-4">Support</h3>
              <ul className="space-y-2">
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">Help Center</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">Contact Us</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">System Status</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">API Documentation</a></li>
                <li><a href="#" className="text-green-200 hover:text-white transition-colors">Privacy Policy</a></li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-green-800 mt-8 pt-8 text-center">
            <p className="text-green-300">
              © 2024 SAS Electric Fence Detection System. All rights reserved. | 
              <span className="ml-2">Powered by Advanced AI & Real-time Analytics</span>
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}