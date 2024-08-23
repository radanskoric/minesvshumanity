import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["countdown"]
  static values = { seconds: Number }

  connect() {
    this.countdown = this.secondsValue
    this.updateCountdown()
    this.timer = setInterval(() => {
      this.countdown--
      if (this.countdown >= 0) {
        this.updateCountdown()
      } else {
        this.stopCountdown()
        this.refreshPage()
      }
    }, 1000)
  }

  disconnect() {
    this.stopCountdown()
  }

  updateCountdown() {
    this.countdownTarget.textContent = this.countdown
  }

  stopCountdown() {
    clearInterval(this.timer)
  }

  refreshPage() {
    // TODO: move to refresh, see TODO.md
    document.location = document.baseURI
  }
}
