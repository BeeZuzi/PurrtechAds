import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  navigate(event) {
    window.location.href = `/locale/${event.target.value}`
  }
}
