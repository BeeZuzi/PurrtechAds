import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "dot", "nextBtn", "prevBtn", "submitBtn"]

  connect() {
    this.currentStep = 0
    this.showStep(this.currentStep)
  }

  next() {
    if (!this.validateCurrentStep()) return
    if (this.currentStep < this.stepTargets.length - 1) {
      this.currentStep++
      this.showStep(this.currentStep)
    }
  }

  prev() {
    if (this.currentStep > 0) {
      this.currentStep--
      this.showStep(this.currentStep)
    }
  }

  validateCurrentStep() {
    const inputs = this.stepTargets[this.currentStep].querySelectorAll("input[required], select[required], textarea[required]")
    for (const input of inputs) {
      if (!input.checkValidity()) {
        input.reportValidity()
        return false
      }
    }
    return true
  }

  showStep(index) {
    this.stepTargets.forEach((step, i) => step.classList.toggle("active", i === index))
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("active", i === index)
      dot.classList.toggle("done", i < index)
    })
    this.prevBtnTarget.style.visibility = index === 0 ? "hidden" : "visible"
    this.nextBtnTarget.style.display = index === this.stepTargets.length - 1 ? "none" : "inline-flex"
    this.submitBtnTarget.style.display = index === this.stepTargets.length - 1 ? "inline-flex" : "none"
  }
}