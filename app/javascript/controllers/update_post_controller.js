import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'message' ]

  async submit (event) {
    event.preventDefault()
    let form = this.element
    let body = new FormData(form)
    let action = form.action
    let result = await fetch(action, {
      credentials: 'same-origin',
      method: 'POST',
      body: body
    })
    let json = await result.json()
    if (result.ok) {
      this.messageTarget.innerHTML = `
        Post updated <strong><i class="far fa-thumbs-up"></i></strong>
      `
    } else {
      this.messageTarget.textContent = json.errors
    }
  }

}
