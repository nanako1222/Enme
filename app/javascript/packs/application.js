import "../stylesheets/application.scss"
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import jQuery from "jquery"
import "bootstrap"

window.$ = window.jQuery = jQuery;
Rails.start()
ActiveStorage.start()

// documentへのイベント委譲（Turbolinksでページ遷移しても外れない）
document.addEventListener('change', function(e) {
  if (!e.target.matches('select[id*="state_id"]')) return;

  const stateId = e.target.value;
  const elementId = e.target.id;
  const targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";
  const targetElement = document.querySelector(targetSelector);

  if (stateId && targetElement) {
    fetch(`/areas?state_id=${stateId}`)
      .then(response => response.text())
      .then(html => {
        const selectEl = targetElement.querySelector('select');
        if (selectEl) {
          selectEl.innerHTML = html;
        } else {
          targetElement.innerHTML = html;
        }
      });
  }
});
