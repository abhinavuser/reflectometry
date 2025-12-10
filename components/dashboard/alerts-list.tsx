import { ScrollArea } from "../ui/scroll-area"
import { Card, CardContent, CardHeader, CardTitle } from "../ui/card"
import { Badge } from "../ui/badge"
import { AlertTriangle, CheckCircle, XCircle } from "lucide-react"

export function AlertsList({ alerts }) {
  const getAlertIcon = (type) => {
    switch (type.toLowerCase()) {
      case 'success':
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case 'warning':
        return <AlertTriangle className="h-4 w-4 text-yellow-500" />
      case 'critical':
        return <XCircle className="h-4 w-4 text-red-500" />
      default:
        return <AlertTriangle className="h-4 w-4 text-muted-foreground" />
    }
  }

  const getAlertVariant = (type) => {
    switch (type.toLowerCase()) {
      case 'success':
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
      <CardHeader>
        <CardTitle className="text-lg font-medium">Recent Alerts</CardTitle>
      </CardHeader>
      <CardContent>
        <ScrollArea className="h-[300px]">
          <div className="space-y-4">
            {alerts.map((alert) => (
              <div
                key={alert.id}
                className="flex items-start gap-4 rounded-lg border p-4"
              >
                {getAlertIcon(alert.type)}
                <div className="grid gap-1">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-medium">{alert.message}</p>
                    <Badge variant={getAlertVariant(alert.type)} className="h-5">
                      {alert.type}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <span>{new Date(alert.timestamp).toLocaleTimeString()}</span>
                    <span>•</span>
                    <span>{alert.substation}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </ScrollArea>
      </CardContent>
    </Card>
  )
}
