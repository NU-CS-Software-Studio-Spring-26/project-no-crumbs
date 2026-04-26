import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["display", "hidden"]

  connect() {
    const initial = this.hiddenTarget.value || null

    this.picker = flatpickr(this.displayTarget, {
      enableTime: true,
      dateFormat: "F j, Y \\a\\t h:i K",
      minuteIncrement: 15,
      defaultDate: initial,
      disableMobile: true,
      onChange: ([date]) => {
        if (!date) return
        const pad = n => String(n).padStart(2, "0")
        this.hiddenTarget.value =
          `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
          `T${pad(date.getHours())}:${pad(date.getMinutes())}`
      }
    })
  }

  disconnect() {
    this.picker?.destroy()
  }
}
