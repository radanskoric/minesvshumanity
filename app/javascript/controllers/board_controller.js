import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'

const turboContentType = "text/vnd.turbo-stream.html";

// The controller is responsible for capturing interactions
// on board cells and acting on it.
export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.element.addEventListener("click", this.move.bind(this))
    this.element.addEventListener("contextmenu", this.move.bind(this))
  }

  move(event) {
    event.preventDefault()
    const cell = event.target;
    if(!cell.classList.contains("ch")) { return }

    let body = {}
    if(event.type == "contextmenu") {
      body.mark_as_mine = true
    }
    post(this.cellUrl(cell), { headers: {Accept: turboContentType}, body })
  }

  cellUrl(cell) {
    const { x, y } = this.coordinates(cell)
    return this.urlValue.replace("-X-", x).replace("-Y-", y)
  }

  coordinates(cell) {
    const row = cell.parentNode
    return {
      x: this.parentIndex(cell),
      y: this.parentIndex(row)
    }
  }

  parentIndex(element) {
    return Array.from(element.parentNode.children).indexOf(element)
  }
}
