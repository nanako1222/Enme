// 1. CSSのインポート
import "../stylesheets/application.scss"

// 2. 基本ライブラリ
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import jQuery from "jquery"
import "popper.js"
import "bootstrap"

// グローバル設定
window.$ = window.jQuery = jQuery;

Rails.start()
ActiveStorage.start()

// --- 地域のプルダウン連動機能 (修正版) ---
// documentに対してイベントを設定することで、ページが切り替わっても確実に動作させます
$(document).on('change', '[id*="state_id"]', function() {
  var stateId = $(this).val();
  var elementId = $(this).attr('id');
  console.log("都道府県の変更を検知: " + elementId + " (選択されたID: " + stateId + ")");

  // ターゲットの判定（顧客用か店舗用か）
  var targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";
  
  // 選択が空（未選択）の場合はエリアをリセット
  if (!stateId) {
    $(targetSelector).html('<option value="">選択してください</option>');
    return;
  }

  // Ajax通信
  $.ajax({
    url: '/areas',
    type: 'GET',
    data: { state_id: stateId },
    dataType: 'html',
    beforeSend: function() {
      console.log("Ajax送信開始...");
    }
  }).done(function(data){
    console.log("Ajax成功: " + targetSelector + " を更新します");
    $(targetSelector).html(data);
  }).fail(function(xhr, status, error){
    console.error("Ajax失敗:", error);
    alert("エリアの取得に失敗しました。ページを再読み込みしてください。");
  });
});

console.log("Application.js has been loaded!");
