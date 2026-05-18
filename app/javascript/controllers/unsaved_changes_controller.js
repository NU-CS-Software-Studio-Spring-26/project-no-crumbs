import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dirty = false
    this.onInput = () => { this.dirty = true }
    this.onBeforeVisit = (e) => {
      if (this.dirty && !confirm("You have unsaved changes. Leave anyway?")) {
        e.preventDefault()
      }
    }

    this.element.addEventListener("input", this.onInput)
    document.addEventListener("turbo:before-visit", this.onBeforeVisit)
  }

  disconnect() {
    this.element.removeEventListener("input", this.onInput)
    document.removeEventListener("turbo:before-visit", this.onBeforeVisit)
  }

  submit() {
    this.dirty = false
  }
}
