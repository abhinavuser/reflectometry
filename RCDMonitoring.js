import { Card, CardContent, CardHeader, CardTitle } from "./ui/card"
import { Badge } from "./ui/badge"
import { Progress } from "./ui/progress"

export function RCDMonitoring({ isLoading, error, data }) {
  if (error) {
    return (
      <div className="p-4 border border-destructive/50 bg-destructive/10 rounded-lg">
        <p className="text-sm text-destructive">{error}</p>
      </div>
    )
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-40">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (!data?.sectorStatus) {
    return (
      <div className="p-4 border border-muted bg-muted/10 rounded-lg">
        <p className="text-sm text-muted-foreground">No RCD data available</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-card rounded-lg p-4 border">
          <div className="text-sm text-muted-foreground">Total RCDs</div>
          <div className="text-2xl font-bold mt-1">{data.statusSummary?.totalRCDs || 0}</div>
        </div>
        <div className="bg-card rounded-lg p-4 border">
          <div className="text-sm text-muted-foreground">Active RCDs</div>
          <div className="text-2xl font-bold mt-1 text-green-600">{data.statusSummary?.activeRCDs || 0}</div>
        </div>
        <div className="bg-card rounded-lg p-4 border">
          <div className="text-sm text-muted-foreground">Faulted RCDs</div>
          <div className="text-2xl font-bold mt-1 text-destructive">{data.statusSummary?.faultedRCDs || 0}</div>
        </div>
        <div className="bg-card rounded-lg p-4 border">
          <div className="text-sm text-muted-foreground">Trips Today</div>
          <div className="text-2xl font-bold mt-1 text-orange-500">{data.statusSummary?.totalTripsToday || 0}</div>
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {data.sectorStatus.map((sector, index) => (
          <div key={index} className="p-4 bg-card rounded-lg border">
            <div className="flex justify-between items-start mb-2">
              <h3 className="font-medium">{sector.sectorId}</h3>
              <Badge variant={sector.rcdsActive === sector.rcdsInstalled ? 'success' : 'destructive'}>
                {sector.rcdsActive}/{sector.rcdsInstalled} Active
              </Badge>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Average Leakage:</span>
                <span>{sector.averageLeakage}mA</span>
              </div>
              <Progress value={(sector.averageLeakage / 30) * 100} />
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Last Trip:</span>
                <span>{sector.lastTrip ? new Date(sector.lastTrip).toLocaleString() : 'N/A'}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
