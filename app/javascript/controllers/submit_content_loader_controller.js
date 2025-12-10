import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ 'container' ]
  static values = { url: String }

  load () {
    fetch(this.urlValue, {credentials: 'same-origin'})
      .then(response => response.text())
      .then(html => {
        this.containerTarget.innerHTML = html
      })
  }
}
