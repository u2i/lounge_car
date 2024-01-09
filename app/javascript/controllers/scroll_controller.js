import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  connect() {}

  scrollToBottom(event) {
    const messagesContainer = document.getElementById("messages");
    const max_scroll = messagesContainer.scrollHeight - messagesContainer.clientHeight;
    if (max_scroll - 200 < messagesContainer.scrollTop) {
      messagesContainer.scrollTop = max_scroll;
    }
  }
}
