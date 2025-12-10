import { ThemeProvider } from '../components/theme-provider'
import 'leaflet/dist/leaflet.css'
import '../styles/globals.css'
import '../styles/animations.css'
import '../styles/geospatial-map.css'

export default function App({ Component, pageProps }) {
  return (
    <ThemeProvider>
      <Component {...pageProps} />
    </ThemeProvider>
  )
}
