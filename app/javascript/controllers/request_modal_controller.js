import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop"]

  connect() {
    this.handleKeydown = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    document.body.style.overflow = ""
  }

  open() {
    if (!this.hasBackdropTarget) return
    this.backdropTarget.hidden = false
    document.body.style.overflow = "hidden"
  }

  close() {
    if (!this.hasBackdropTarget) return
    this.backdropTarget.hidden = true
    document.body.style.overflow = ""
  }

  backdropClick(event) {
    if (event.target === this.backdropTarget) this.close()
  }
}
