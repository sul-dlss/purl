import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form']

  connect() {
    this.formTarget['user_agent'].value = navigator.userAgent
    this.formTarget['viewport'].value = `width: ${window.innerWidth} height: ${innerHeight}`
  }
}