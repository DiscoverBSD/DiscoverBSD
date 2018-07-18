import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'container' ]

  load () {
    fetch(this.data.get('url'), {credentials: 'same-origin'})
      .then(response => response.text())
      .then(html => {
        this.containerTarget.innerHTML = html
      })
  }
}
