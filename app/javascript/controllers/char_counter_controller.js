import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]

  connect() {
    this.update()
  }

  update() {
    const max = this.inputTarget.maxLength
    const length = this.inputTarget.value.length
    this.counterTarget.textContent = `${length} / ${max}`
    this.counterTarget.classList.toggle("near-limit", length > max * 0.9)
  }
}