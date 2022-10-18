/*global $*/
$(document).ready(function(){
  $('#customer_states_id').change(function() {
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
