import { Controller } from "@hotwired/stimulus"
import { EditorView, basicSetup } from "codemirror"
import { EditorState, StateEffect } from "@codemirror/state"
import { languages } from "@codemirror/language-data"
import { oneDark } from "@codemirror/theme-one-dark"
let view = {};

export default class extends Controller {
  static targets = [ "textarea", "file", "form", "clearFileButton", "fullSize" ]
  static classes = [ "filled", "fullSize" ]
  static values = { readOnly: { type: Boolean, default: false }, extensions: Array }

  textareaTargetConnected() {
    // CodeMirror setup, based on the existing TextArea
    // if TextArea has display: none, we assume this has been set up already
    if (this.textareaTarget.style['display'] != 'none') {
      let extensions = [basicSetup];
      if (this.readOnlyValue)
        extensions.push(EditorState.readOnly.of(true));
      view = new EditorView({extensions})
      let value = this.textareaTarget.value;
      let changes = [{ from: 0, insert: value }]
      view.dispatch({changes});
      this.textareaTarget.parentNode.insertBefore(view.dom, this.textareaTarget);
      this.textareaTarget.style.display = "none";
      this.setLanguage();
      this.setMode();
    }
  }

  clearFileButtonTargetConnected() {
    // Hide the 'Clear' button next to File by default
    this.clearFileButtonTarget.classList.add(this.filledClass);
  }

  connect() {
    // If the page loads with filled TextArea or File field, handle those
    if (this.hasFileTarget && this.hasTextareaTarget) {
      this.hideText();
      this.hideFile();
    }
  }

  submit() {
    // Get CodeMirror contents to TextArea on submit
    this.textareaTarget.value = view.state.doc.toString()
  }

  hideFile() {
    // Hides File input if the TextArea isn't empty
    if (this.textareaTarget.value != '' || view.state.doc.toString() != '') {
      this.fileTarget.value = '';
      this.fileTarget.parentNode.style.display = 'none';
    }
    else
      this.fileTarget.parentNode.style.display = '';
  }

  hideText() {
    // Hides TextArea if the File input isn't empty
    if (this.fileTarget.value != '') {
      this.textareaTarget.value = '';
      let value = view.state.doc.toString();
      let changes = [{ from: 0, to: value.length, insert: '' }]
      view.dispatch({changes});
      this.textareaTarget.parentNode.parentNode.style.display = 'none';
      this.clearFileButtonTarget.classList.remove(this.filledClass);
    }
    else {
      this.textareaTarget.parentNode.parentNode.style.display = '';
      this.clearFileButtonTarget.classList.add(this.filledClass);
    }
  }

  clearFile() {
    // Clear File input after it was filled out
    this.fileTarget.value = "";
    this.textareaTarget.parentNode.parentNode.style.display = '';
    this.clearFileButtonTarget.classList.add(this.filledClass);
  }

  setMode() {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      view.dispatch({
        effects: [StateEffect.appendConfig.of([ oneDark ])]
      });
    }
  }

  setLanguage() {
    if (this.extensionsValue) {
      let languageData = languages.find(
        (lang) => lang.extensions.some(item => this.extensionsValue.includes(item))
      );
      if (languageData) {
        this.setHighlighting(languageData).then(res => {
          view.dispatch({
            effects: [StateEffect.appendConfig.of([res])]
          });
        });
      }
    }
  }

  async setHighlighting(languageData) {
    return await languageData.load();
  }

  expand() {
    this.fullSizeTarget.classList.add(this.fullSizeClass)
  }

  contract() {
    this.fullSizeTarget.classList.remove(this.fullSizeClass)
  }
}
