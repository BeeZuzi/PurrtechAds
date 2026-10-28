import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Makes a whole table row open its link. The link inside stays a real <a>, so
// keyboard, middle-click and "open in new tab" still work.
export default class extends Controller {
  static values = { url: String }

  open(event) {
    if (event.target.closest("a, button, input, select, textarea")) return
    if (window.getSelection().toString()) return

    if (event.metaKey || event.ctrlKey) {
      window.open(this.urlValue, "_blank")
    } else {
      Turbo.visit(this.urlValue)
    }
  }
}
