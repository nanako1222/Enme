/*global $*/

// 関数として独立させる
function initAreaSelect() {
  console.log("Area selector initialized"); // これがコンソールに出れば成功

  // 顧客用
  $(document).off('change', '#customer_state_id').on('change', '#customer_state_id', function() {
    console.log("State changed: " + $(this).val());
    $.ajax({
      url: '/areas',
      type: 'GET',
      data: { type: "customer", state_id: $(this).val() }
    }).done(function(data){
      $('#areas_select_customer').html(data);
    });
  });

  // 飲食店・管理者用
  $(document).off('change', '#restaurant_state_id, #admin_state_id').on('change', '#restaurant_state_id, #admin_state_id', function() {
    var typeName = $(this).attr('id').includes('admin') ? "restaurant" : "restaurant"; 
    $.ajax({
      url: '/areas',
      type: 'GET',
      data: { type: typeName, state_id: $(this).val() }
    }).done(function(data){
      $('#areas_select').html(data);
    });
  });
}

// ページ読み込みのあらゆるタイミングで実行
$(document).on('turbolinks:load', initAreaSelect);
$(document).ready(initAreaSelect);
