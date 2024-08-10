import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.loadDashboardData()
  }

  loadDashboardData() {
    fetch('/fetch_dashboard_data', {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => {
        document.getElementById("dashboard-data").innerHTML = html
      })
      .catch(error => console.error('Error fetching dashboard data:', error))
  }
}
