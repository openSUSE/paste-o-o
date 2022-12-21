import { Controller } from "@hotwired/stimulus"
import {EditorView, basicSetup} from "codemirror"
import {EditorState} from "@codemirror/state"
let view = {};

export default class extends Controller {
  static targets = [ "textarea", "file", "form", "clearFileButton" ]
  static classes = [ "filled" ]
  static values = { readOnly: { type: Boolean, default: false } }

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
      this.textareaTarget.parentNode.style.display = 'none';
      this.clearFileButtonTarget.classList.remove(this.filledClass);
    }
    else {
      this.textareaTarget.parentNode.style.display = '';
      this.clearFileButtonTarget.classList.add(this.filledClass);
    }
  }

  clearFile() {
    // Clear File input after it was filled out
    this.fileTarget.value = "";
    this.textareaTarget.parentNode.style.display = '';
    this.clearFileButtonTarget.classList.add(this.filledClass);
  }
}
