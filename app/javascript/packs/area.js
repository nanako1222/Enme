/*global $*/
$(document).ready(function(){
  $('#customer_farm_states').change(function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select').html(data)
    })
  })
});
