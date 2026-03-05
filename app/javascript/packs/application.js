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
  // すでに登録されているイベントを一度クリアしてから再登録
  $(document).off('change', '[id*="state_id"]');
  
  $(document).on('change', '[id*="state_id"]', function() {
    // $(this) を使って、今まさに変更された要素から値を取得する
    var stateId = $(this).val();
    var elementId = $(this).attr('id');
    
    console.log("選択された都道府県ID: " + stateId); // これで検証コンソールに値が出るか確認

    var targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";
    var $target = $(targetSelector);

    if (stateId) {
      $.ajax({
        url: '/areas',
        type: 'GET',
        data: { state_id: stateId }, // ここで選んだIDがサーバーに飛びます
        dataType: 'html',
        success: function(data) {
          $target.html(data);
        },
        error: function() {
          console.log("エリアの取得に失敗しました");
        }
      });
    } else {
      $target.html('<option value="">地域を選択してください</option>');
    }
  });
});
