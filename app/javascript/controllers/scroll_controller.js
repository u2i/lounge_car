import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {}

  lastScrollTime = Date.now();

  scroll = () => {
    const messagesContainer = document.getElementById("messages");
    const max_scroll = messagesContainer.scrollHeight - messagesContainer.clientHeight;
    if (max_scroll - 200 < messagesContainer.scrollTop) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }

  throttledScroll = () => {
    if (this.lastScrollTime + 1000 < Date.now()) {
      this.lastScrollTime = Date.now();
      setTimeout(this.scroll, 50);
    }
  }
}
