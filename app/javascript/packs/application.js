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

$(document).on('turbolinks:load', function() {
  // 以前のイベントを確実に消去
  $(document).off('change', 'select[id*="state_id"]');

  // 都道府県セレクトボックスの変更を検知
  $(document).on('change', 'select[id*="state_id"]', function(e) {
    // 変更された要素そのものから値を取得
    var stateId = $(e.target).val();
    var elementId = $(e.target).attr('id');
    
    console.log("Change detected on: " + elementId + " value: " + stateId);

    // 顧客用か店舗用かのターゲット判定
    var targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";
    var $target = $(targetSelector);

    if (stateId) {
      $.ajax({
        url: '/areas',
        type: 'GET',
        data: { state_id: stateId }, // ここで選択したIDを送信
        dataType: 'text' // コントローラーが render plain なので text
      }).done(function(data) {
        $target.html(data);
        console.log("Areas updated for state: " + stateId);
      }).fail(function() {
        console.error("Ajax Error: Failed to fetch areas.");
      });
    } else {
      $target.html('<option value="">選択してください</option>');
    }
  });
});
