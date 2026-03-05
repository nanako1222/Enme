import "../stylesheets/application.scss"
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import jQuery from "jquery"
import "popper.js"
import "bootstrap"

window.$ = window.jQuery = jQuery;
Rails.start()
ActiveStorage.start()

// ページ読み込み完了時に実行
function initAreaSelect() {
  console.log("JavaScript initialized");
  
  // 都道府県セレクトボックスを探してイベントを登録
  const stateSelects = document.querySelectorAll('select[id*="state_id"]');
  stateSelects.forEach(select => {
    select.addEventListener('change', function(e) {
      const stateId = e.target.value;
      const elementId = e.target.id;
      console.log("Changed: " + elementId + " Value: " + stateId);

      const targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";
      const targetElement = document.querySelector(targetSelector);

      if (stateId && targetElement) {
        fetch(`/areas?state_id=${stateId}`)
          .then(response => response.text())
          .then(html => {
            targetElement.innerHTML = html;
            console.log("Updated target with HTML");
          });
      }
    });
  });
}

// Turbolinksと通常読み込みの両方に対応
document.addEventListener("turbolinks:load", initAreaSelect);
// 万が一のために即時実行も試みる
if (document.readyState !== 'loading') {
  initAreaSelect();
}
