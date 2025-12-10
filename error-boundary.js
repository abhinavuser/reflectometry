import { Component } from 'react'

export class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="p-4 border border-destructive/50 bg-destructive/10 rounded-lg">
          <h3 className="font-medium text-destructive mb-2">Something went wrong</h3>
          <p className="text-sm text-muted-foreground">{this.state.error?.message}</p>
        </div>
      )
    }

    return this.props.children
  }
}
