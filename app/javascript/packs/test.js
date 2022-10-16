/*global $*/
$(function(){
  $("#customer_farm_states").on('change', function () {
    $.ajax('/companies/cities_select', {
      type: 'GET',
      data: {
        ms_pref_id: $(this).val()
      }
    }).done(function(data){
      $('#customer_farm_area').html(data)
    })
  })
})
