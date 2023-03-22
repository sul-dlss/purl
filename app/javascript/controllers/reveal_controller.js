import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "area" ]

  toggle() {
    const el = this.areaTarget
    if (el.style.display == 'none') {
      el.style.display = '';
    } else {
      el.style.display = 'none';
    }
  }
}