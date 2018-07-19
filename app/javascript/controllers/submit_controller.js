import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'error', 'form' ]

  async submit (event) {
    event.preventDefault()
    let form = this.formTarget
    let body = new FormData(form)
    let action = form.action
    let result = await fetch(action, {
      credentials: 'same-origin',
      method: 'POST',
      body: body
    })
    let json = await result.json()
    if (result.ok) {
      this.formTarget.parentNode.parentNode.innerHTML = `
        <div class="notification">
          <strong>Thanks <i class="far fa-thumbs-up"></i></strong>
          We will try to review and approve your post ASAP.
        </div>
      `
    } else {
      this.errorTarget.textContent = json.errors
    }
  }

}
