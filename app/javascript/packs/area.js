/*global $*/
function initAreaSelect() {
  console.log("Checking for dropdowns...");

  // [重要] ID指定を「state_id」という文字を含むもの全て、に広げます
  $(document).off('change', '[id*="state_id"]').on('change', '[id*="state_id"]', function() {
    var stateId = $(this).val();
    var elementId = $(this).attr('id');
    console.log("Detected change in: " + elementId + " value: " + stateId);

    // どの画面（顧客/店舗/管理者）にいるかを自動判別
    var type = "restaurant";
    var targetSelector = "#areas_select";

    if (elementId.includes("customer")) {
      type = "customer";
      targetSelector = "#areas_select_customer";
    }

    $.ajax({
      url: '/areas',
      type: 'GET',
      data: { type: type, state_id: stateId }
    }).done(function(data){
      console.log("Ajax success! Updating: " + targetSelector);
      $(targetSelector).html(data);
    }).fail(function(){
      console.log("Ajax failed. Check if /areas route exists.");
    });
  });
}

$(document).on('turbolinks:load', initAreaSelect);
$(document).ready(initAreaSelect);
