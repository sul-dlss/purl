import ace from 'ace-builds';

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "input", "output" ]

  connect() {
    ace.config.set('basePath', 'https://cdn.jsdelivr.net/npm/ace-builds@1.16.0/src-noconflict/')

    var editor = ace.edit("mods")
    editor.setTheme("ace/theme/monokai")
    editor.getSession().setMode("ace/mode/xml")
    this.outputTarget.style.fontSize = '16px'

    const textarea = this.inputTarget
    textarea.style.display = 'none'
    editor.getSession().setValue(textarea.value)

    editor.getSession().on('change', () => {
      textarea.value = editor.getSession().getValue()
    })
  }
}