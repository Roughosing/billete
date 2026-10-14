import { Controller } from "@hotwired/stimulus"

// Auto-dismissing notification. Pauses the timer while hovered or focused so
// a message can't disappear while someone is reading or about to click it.
export default class extends Controller {
  static values = { timeout: { type: Number, default: 6000 } }

  connect() {
    this.start()
    this.element.addEventListener("mouseenter", this.stop)
    this.element.addEventListener("mouseleave", this.start)
    this.element.addEventListener("focusin", this.stop)
    this.element.addEventListener("focusout", this.start)
  }

  disconnect() {
    this.stop()
  }

  start = () => {
    this.stop()
    this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  stop = () => {
    if (this.timer) clearTimeout(this.timer)
    this.timer = null
  }

  dismiss() {
    this.stop()
    this.element.classList.add("is-leaving")
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
    // Fallback for reduced-motion environments where animationend may not fire.
    setTimeout(() => this.element.remove(), 400)
  }
}
