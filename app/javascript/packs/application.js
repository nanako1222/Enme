k// 1. CSSをJavaScript経由でWebpackerに認識させる（最重要！）
import "../stylesheets/application.scss"

// 2. 基本ライブラリのインポート
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import jQuery from "jquery"
import "popper.js"
import "bootstrap"

// 3. グローバル設定：これでJSから $ が使えるようになります
window.$ = window.jQuery = jQuery;

Rails.start()
ActiveStorage.start()

// 4. 地域のプルダウン連動機能
$(document).on('turbolinks:load', function() {
  console.log("Application.js: DOM Loaded");

  $(document).off('change', '[id*="state_id"]').on('change', '[id*="state_id"]', function() {
    var stateId = $(this).val();
    var elementId = $(this).attr('id');
    console.log("Detected state change in: " + elementId + " (ID: " + stateId + ")");

    // 顧客(customer)か店舗(restaurant)かをID名から判定
    var targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";

    if (stateId) {
      $.ajax({
        url: '/areas',
        type: 'GET',
        data: { state_id: stateId },
        dataType: 'html'
      }).done(function(data){
        console.log("Ajax success: Updating " + targetSelector);
        $(targetSelector).html(data);
      }).fail(function(){
        console.log("Ajax failed. Check server logs.");
      });
    }
  });
});

// update for css fix
