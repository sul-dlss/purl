import { Controller } from "@hotwired/stimulus"

export default class ClipboardController extends Controller {
  static values = {
    url: String
  }

  copy(event) {
    navigator.clipboard.writeText(this.urlValue)

    event.preventDefault()
  }
}
