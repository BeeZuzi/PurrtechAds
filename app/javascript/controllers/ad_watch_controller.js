import { Controller } from "@hotwired/stimulus"

// Simulates a rewarded ad while a real ad network isn't wired in yet.
// Server-side watch-duration verification belongs to the anti-fraud phase.
export default class extends Controller {
  static targets = ["timer", "progress", "claimButton"]
  static values = {
    duration: { type: Number, default: 8 },
    remainingText: { type: String, default: "%{seconds}s remaining…" },
    finishedText: { type: String, default: "Ad finished — claim your reward!" }
  }

  connect() {
    this.remaining = this.durationValue
    this.render()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  tick() {
    this.remaining -= 1
    this.render()

    if (this.remaining <= 0) {
      clearInterval(this.interval)
      this.claimButtonTarget.disabled = false
      this.timerTarget.textContent = this.finishedTextValue
    }
  }

  render() {
    if (this.hasTimerTarget && this.remaining > 0) {
      this.timerTarget.textContent = this.remainingTextValue.replace("%{seconds}", this.remaining)
    }

    if (this.hasProgressTarget) {
      const watched = this.durationValue - Math.max(this.remaining, 0)
      const pct = Math.min(100, (watched / this.durationValue) * 100)
      this.progressTarget.style.width = `${pct}%`
    }
  }
}
