import { RCDMonitoring } from '../components/RCDMonitoring'

export default function SASElectricFenceDetection() {
  const [currentTime, setCurrentTime] = useState(new Date())
  const [connectionStatus, setConnectionStatus] = useState('CONNECTING')
  const [activeTab, setActiveTab] = useState('main')
  const [searchQuery, setSearchQuery] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)
  const [alertCount, setAlertCount] = useState(0)
  const [rcdStatus, setRcdStatus] = useState(null)

  // Effect for RCD status
  useEffect(() => {
    const fetchRCDStatus = async () => {
      try {
        setIsLoading(true)
        setError(null)
        const response = await fetch('/api/sas/rcd-status')
        if (!response.ok) {
          throw new Error(`RCD Status API failed: ${response.statusText}`)
        }
        const data = await response.json()
        setRcdStatus(data)
      } catch (err) {
        console.error('Error fetching RCD status:', err)
        setError(err.message)
      } finally {
        setIsLoading(false)
      }
    }

    fetchRCDStatus()
    const interval = setInterval(fetchRCDStatus, 30000)
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Residual Current Device Monitoring</CardTitle>
        </CardHeader>
        <CardContent>
          {error ? (
            <div className="p-4 border border-destructive/50 bg-destructive/10 rounded-lg">
              <p className="text-sm text-destructive">{error}</p>
            </div>
          ) : isLoading ? (
            <div className="flex items-center justify-center h-40">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            </div>
          ) : !rcdStatus ? (
            <div className="p-4 border border-muted bg-muted/10 rounded-lg">
              <p className="text-sm text-muted-foreground">No RCD data available</p>
            </div>
          ) : (
            <RCDMonitoring data={rcdStatus} />
          )}
        </CardContent>
      </Card>
    </div>
  )
}
