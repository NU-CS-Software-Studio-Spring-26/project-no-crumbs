import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "button", "badge", "overlay", "mealInput"]

  generate() {
    const title = this.titleTarget.value.trim()
    if (!title) {
      this.titleTarget.focus()
      this.titleTarget.classList.add("is-invalid")
      setTimeout(() => this.titleTarget.classList.remove("is-invalid"), 1500)
      return
    }

    this.mealInputTarget.value = ""
    this.overlayTarget.style.display = "flex"
    this.mealInputTarget.focus()
  }

  cancelOverlay() {
    this.overlayTarget.style.display = "none"
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.cancelOverlay()
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.confirmOverlay()
    }
  }

  async confirmOverlay() {
    const title = this.titleTarget.value.trim()
    const mealDescription = this.mealInputTarget.value.trim()

    if (!mealDescription) {
      this.mealInputTarget.classList.add("is-invalid")
      this.mealInputTarget.focus()
      setTimeout(() => this.mealInputTarget.classList.remove("is-invalid"), 1500)
      return
    }

    this.overlayTarget.style.display = "none"

    const btn = this.buttonTarget
    btn.disabled = true
    btn.innerHTML = '<span class="ai-btn-spinner"></span> Thinking…'

    try {
      const resp = await fetch("/posts/generate_description", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ title, meal_description: mealDescription })
      })
      const data = await resp.json()
      if (data.description) {
        this.descriptionTarget.value = data.description
        this.descriptionTarget.dispatchEvent(new Event("input"))
        this.badgeTarget.classList.remove("d-none")
      }
    } catch {
      // silently fail — user can still type manually
    } finally {
      btn.disabled = false
      btn.innerHTML = '✨ AI suggest'
    }
  }

  clearBadge() {
    this.badgeTarget.classList.add("d-none")
  }
}
