import { Controller } from '@hotwired/stimulus'

export default class OembedController extends Controller {
  connect() {
    const loadedAttr = this.element.getAttribute('loaded')

    if (loadedAttr && loadedAttr === 'loaded') {
      return
    }

    const oEmbedEndPoint = document.head.querySelector('link[rel="alternate"][type="application/json+oembed"]')?.getAttribute('href')
    if (!oEmbedEndPoint) {
      console.warn(`No oEmbed endpoint found in <head>`)
      return
    }
    this.loadEndPoint(oEmbedEndPoint)
  }

  loadEndPoint(oEmbedEndPoint) {
    fetch(oEmbedEndPoint)
      .then((response) => response.json())
      .then((json) => {
        this.element.innerHTML = json.html
        this.element.setAttribute('loaded', 'loaded')
      })
  }
}
