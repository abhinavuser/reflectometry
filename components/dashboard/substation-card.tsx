import { Card, CardContent, CardHeader, CardTitle } from "../ui/card"
import { Badge } from "../ui/badge"
import { Progress } from "../ui/progress"
import { Activity, AlertTriangle, Power } from "lucide-react"

export function SubstationCard({ data }) {
  const getStatusColor = (status) => {
    switch (status.toLowerCase()) {
      case 'operational':
        return 'default'
      case 'warning':
        return 'secondary'
      case 'critical':
        return 'destructive'
      default:
        return 'outline'
    }
  }

  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-base font-medium">{data.name}</CardTitle>
          <Badge variant={getStatusColor(data.status)}>{data.status}</Badge>
        </div>
      </CardHeader>
      <CardContent>
        <div className="grid gap-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="flex items-center gap-2">
              <Power className="h-4 w-4 text-muted-foreground" />
              <div className="grid gap-0.5">
                <p className="text-sm font-medium">Voltage</p>
                <p className="text-xs text-muted-foreground">{data.voltage}kV</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Activity className="h-4 w-4 text-muted-foreground" />
              <div className="grid gap-0.5">
                <p className="text-sm font-medium">Current</p>
                <p className="text-xs text-muted-foreground">{data.current}A</p>
              </div>
            </div>
          </div>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <AlertTriangle className="h-4 w-4 text-muted-foreground" />
              <p className="text-sm">Alerts: {data.alerts}</p>
            </div>
            <Progress value={data.power} max={50} className="w-1/2 h-2" />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
