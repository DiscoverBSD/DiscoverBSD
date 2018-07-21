import { Controller } from 'stimulus'

export default class extends Controller {

  load () {
    fetch(this.data.get('url'), {credentials: 'same-origin'})
      .then(response => response.text())
      .then(html => {
        this.element.style.visibility = 'hidden'
        this.element.closest('.container').innerHTML += html
      })
  }
}
