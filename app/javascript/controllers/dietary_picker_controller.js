import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.target.closest(".dietary-check").classList.toggle("dietary-check--selected", event.target.checked)
  }
}
