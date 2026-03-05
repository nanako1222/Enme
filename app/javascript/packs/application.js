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
  // 都道府県プルダウンの変更を検知
  $(document).on('change', '[id*="state_id"]', function() {
    var stateId = $(this).val();
    var elementId = $(this).attr('id');
    
    // ターゲット判定（ID名にcustomerが含まれるかどうか）
    var targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";
    var $target = $(targetSelector);

    if (stateId) {
      $.ajax({
        url: '/areas',
        type: 'GET',
        data: { state_id: stateId },
        dataType: 'html'
      }).done(function(data) {
        // 取得した <option> タグ群を流し込む
        $target.html(data);
        // プルダウンとして反応させるため、一番上を選択状態にする
        $target.prop('selectedIndex', 0);
      }).fail(function() {
        console.log("エリア取得失敗");
      });
    } else {
      $target.html('<option value="">地域を選択してください</option>');
    }
  });
});
