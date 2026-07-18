import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "fab", "themeSwitch", "notifSwitch", "motionSwitch"]

  connect() {
    this.dark = window.matchMedia("(prefers-color-scheme: dark)").matches
    this.applyTheme()

    this.closeHandler = (e) => {
      if (!this.panelTarget.contains(e.target) && !this.fabTarget.contains(e.target)) {
        this.closePanel()
      }
    }
    document.addEventListener("click", this.closeHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.closeHandler)
  }

  togglePanel() {
    const open = this.panelTarget.classList.toggle("visible")
    this.fabTarget.classList.toggle("open", open)
    this.fabTarget.setAttribute("aria-expanded", open)
  }

  closePanel() {
    this.panelTarget.classList.remove("visible")
    this.fabTarget.classList.remove("open")
    this.fabTarget.setAttribute("aria-expanded", "false")
  }

  toggleTheme() {
    this.dark = !this.dark
    this.applyTheme()
  }

  applyTheme() {
    document.documentElement.setAttribute("data-theme", this.dark ? "dark" : "light")
    this.themeSwitchTarget.classList.toggle("on", this.dark)
    this.themeSwitchTarget.setAttribute("aria-checked", this.dark)
  }

  toggleSwitch(event) {
    const el = event.currentTarget
    el.classList.toggle("on")
    el.setAttribute("aria-checked", el.classList.contains("on"))
  }
}