import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Make a request to fetch chart data
    fetch('/fetch_chart_data', {
      headers: { 'Accept': 'text/vnd.turbo-stream.html' }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
  }
}
