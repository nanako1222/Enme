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

// --- ここに地域のプルダウン機能を直接書く ---
$(document).on('turbolinks:load', function() {
  console.log("Application.js is running!");

  $(document).off('change', '[id*="state_id"]').on('change', '[id*="state_id"]', function() {
    var stateId = $(this).val();
    var elementId = $(this).attr('id');
    console.log("State dropdown changed: " + elementId);

    var type = elementId.includes("customer") ? "customer" : "restaurant";
    var targetSelector = elementId.includes("customer") ? "#areas_select_customer" : "#areas_select";

    $.ajax({
      url: '/areas',
      type: 'GET',
      data: { type: type, state_id: stateId }
    }).done(function(data){
      console.log("Ajax success!");
      $(targetSelector).html(data);
    });
  });
});
