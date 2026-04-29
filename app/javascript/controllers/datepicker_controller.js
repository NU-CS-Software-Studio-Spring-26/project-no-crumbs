import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["display", "hidden"]

  connect() {
    const initial = this.element.dataset.datepickerInitialValue

    this.picker = flatpickr(this.displayTarget, {
      enableTime: true,
      dateFormat: "F j, Y \\a\\t h:i K",
      minuteIncrement: 15,
      disableMobile: true,
      onChange: ([date]) => {
        if (!date) return
        const pad = n => String(n).padStart(2, "0")
        this.hiddenTarget.value =
          `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
          `T${pad(date.getHours())}:${pad(date.getMinutes())}`
      }
    })

    if (initial) {
      const [datePart, timePart = "00:00"] = initial.split("T")
      const [y, m, d] = datePart.split("-").map(Number)
      const [h, min] = timePart.split(":").map(Number)
      this.picker.setDate(new Date(y, m - 1, d, h, min), false)
    }
  }

  disconnect() {
    this.picker?.destroy()
  }
}
