import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['message', 'button', 'url', 'suburl', 'title', 'description', 'form']

  async generate(event) {
    event.preventDefault()
    this.buttonTarget.classList.add('is-loading')
    // generation form is down on page, as we can't have form in form
    // so we need to copy the url to the suburl
    this.suburlTarget.value = this.urlTarget.value
    let form = this.formTarget
    let body = new FormData(form)
    let action = form.action
    let result = await fetch(action, {
      credentials: 'same-origin',
      method: 'POST',
      body: body
    })
    let json = await result.json()
    if (result.ok && json.description) {
      this.titleTarget.value = json.title
      this.descriptionTarget.value = json.description
    } else {
      this.messageTarget.textContent = 'Something went wrong, please, try again'
    }
    this.buttonTarget.classList.remove('is-loading')
  }

}
