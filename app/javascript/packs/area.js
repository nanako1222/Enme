/*global $*/
$(document).ready(function(){
  $('#customer_state_id').change(function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "customer",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select').html(data)
    })
  })
});

$(document).ready(function(){
  $('#restaurant_state_id').change(function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "restaurant",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select').html(data)
    })
  })
});