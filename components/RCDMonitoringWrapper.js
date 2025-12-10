import dynamic from 'next/dynamic'
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card'

const RCDMonitoring = dynamic(() => import('./rcd-monitoring'), {
  loading: () => (
    <div className="flex items-center justify-center h-40">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>
  ),
  ssr: false
})
