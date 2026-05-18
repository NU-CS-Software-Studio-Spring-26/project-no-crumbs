import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const len = this.inputTarget.value.length
    this.counterTarget.textContent = `${len} / ${this.maxValue}`
    this.counterTarget.classList.toggle("char-counter--warn", len >= this.maxValue * 0.9)
    this.counterTarget.classList.toggle("char-counter--danger", len > this.maxValue)
  }
}
