import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "button", "badge"]

  async generate() {
    const title = this.titleTarget.value.trim()
    if (!title) {
      this.titleTarget.focus()
      this.titleTarget.classList.add("is-invalid")
      setTimeout(() => this.titleTarget.classList.remove("is-invalid"), 1500)
      return
    }

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
        body: JSON.stringify({ title })
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
