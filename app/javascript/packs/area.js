/*global $*/
$(document).on('turbolinks:load', function() {
  
  // 顧客用：都道府県変更時
  $('#customer_state_id').on('change', function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "customer",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select_customer').html(data)
    })
  });

  // 飲食店用：都道府県変更時
  $('#restaurant_state_id').on('change', function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "restaurant",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select').html(data)
    })
  });

  // 管理者用：飲食店検索の都道府県変更
  $('#admin_state_id').on('change', function() {
    // 飲食店側のセレクトボックスを更新
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "restaurant",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select').html(data)
    });

    // 顧客側のセレクトボックスも更新（必要であれば）
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "customer",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select_customer').html(data)
    });
  });

});
