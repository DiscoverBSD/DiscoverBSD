import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { url: String }

  load () {
    this.element.querySelector('.button').className += ' is-loading'
    fetch(this.urlValue, { credentials: 'same-origin' })
      .then(response => response.text())
      .then(html => {
        this.element.style.display = 'none'
        this.element.closest('.container').innerHTML += html
      })
  }
}
