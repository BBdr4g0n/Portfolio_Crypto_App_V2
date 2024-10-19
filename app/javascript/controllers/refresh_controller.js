import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="refresh"
export default class extends Controller {
  connect() {
    this.startRefreshing()
  }

  disconnect() {
    this.stopRefreshing()
  }

  startRefreshing() {
    this.refreshTimer = setInterval(() => {
      this.refresh()
    }, this.intervalValue || 60000) // Default to 60 seconds if no intervalValue is provided
  }

  stopRefreshing() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
  }

  refresh() {
    // Fetch updates for each partial
    this.refreshPartial('totals')
    //this.refreshPartial('tokens_data')
    //this.refreshPartial('portfolio_distribution')
  }

  refreshPartial(partialId) {
    fetch(`/pages/update_${partialId}`)
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
