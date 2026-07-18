import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fab", "panel", "themeSwitch", "notifSwitch", "motionSwitch", "authTab", "loginForm", "signupForm"]

  connect() {
    this.dark = window.matchMedia("(prefers-color-scheme: dark)").matches
    this.applyTheme()

    this.closeHandler = (e) => {
      if (this.hasPanelTarget && this.hasFabTarget &&
          !this.panelTarget.contains(e.target) && !this.fabTarget.contains(e.target)) {
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
    if (this.hasThemeSwitchTarget) {
      this.themeSwitchTarget.classList.toggle("on", this.dark)
      this.themeSwitchTarget.setAttribute("aria-checked", this.dark)
    }
  }

  toggleSwitch(event) {
    const el = event.currentTarget
    el.classList.toggle("on")
    el.setAttribute("aria-checked", el.classList.contains("on"))
  }

  switchAuthTab(event) {
    const tab = event.currentTarget.dataset.tab
    this.authTabTargets.forEach(t => {
      t.classList.toggle("active", t === event.currentTarget)
      t.setAttribute("aria-selected", t === event.currentTarget)
    })
    this.loginFormTarget.classList.toggle("active", tab === "login")
    this.signupFormTarget.classList.toggle("active", tab === "signin")
  }
}