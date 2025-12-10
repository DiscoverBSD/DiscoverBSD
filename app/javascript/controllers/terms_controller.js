import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ 'checkbox', 'auth' ]

  connect () {
    this.setDisabled()
  }

  setDisabled () {
    this.authTargets.forEach((el) => {
      el.disabled = !this.checkboxTarget.checked
    })
  }

}
