import { Controller } from "@hotwired/stimulus"

// Progressive enhancement for a <details>-based dropdown: closes when the
// user clicks elsewhere, presses Escape, or when Turbo caches the page.
export default class extends Controller {
  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.element.open) {
      this.close()
      this.element.querySelector("summary")?.focus()
    }
  }

  close() {
    this.element.open = false
  }
}
