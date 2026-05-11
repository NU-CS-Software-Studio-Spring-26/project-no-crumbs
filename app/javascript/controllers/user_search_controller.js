import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clear", "form"]

  connect() {
    this._timer = null
  }

  search() {
    this.clearTarget.classList.toggle("d-none", !this.inputTarget.value)
    clearTimeout(this._timer)
    this._timer = setTimeout(() => this.formTarget.requestSubmit(), 300)
  }

  clear(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.clearTarget.classList.add("d-none")
    this.formTarget.requestSubmit()
  }

  disconnect() {
    clearTimeout(this._timer)
  }
}
