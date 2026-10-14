import { Controller } from "@hotwired/stimulus"

// Client-side filtering of an already-rendered list. Each item exposes the
// text to match in data-filter-text. Press "/" anywhere to focus the input.
export default class extends Controller {
  static targets = ["input", "item", "count", "empty"]

  connect() {
    this.apply()
  }

  focus(event) {
    if (event.key !== "/" || event.target.closest("input, textarea, [contenteditable]")) return
    event.preventDefault()
    this.inputTarget.focus()
  }

  clear() {
    this.inputTarget.value = ""
    this.apply()
    this.inputTarget.blur()
  }

  apply() {
    const query = this.inputTarget.value.trim().toLowerCase()
    let visible = 0

    this.itemTargets.forEach((item) => {
      const haystack = (item.dataset.filterText || item.textContent).toLowerCase()
      const match = query === "" || haystack.includes(query)
      item.hidden = !match
      if (match) visible++
    })

    if (this.hasCountTarget) {
      const total = this.itemTargets.length
      this.countTarget.textContent = query === ""
        ? `${total} ${total === 1 ? "event" : "events"}`
        : `${visible} of ${total}`
    }

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible !== 0 || this.itemTargets.length === 0
  }
}
