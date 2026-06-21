/*global $*/
function initAreaSelect() {
  $(document).off('change', '[id*="state_id"]').on('change', '[id*="state_id"]', function() {
    var stateId = $(this).val();
    var formId = $(this).closest('form').attr('id');

    var type, targetSelector;

    if (formId === 'search_restaurant') {
      type = "search";
      targetSelector = "#areas_select_search";
    } else if ($(this).attr('id').includes("customer")) {
      type = "customer";
      targetSelector = "#areas_select_customer";
    } else {
      type = "restaurant";
      targetSelector = "#areas_select";
    }

    $.ajax({
      url: '/areas',
      type: 'GET',
      data: { type: type, state_id: stateId }
    }).done(function(data){
      var $target = $(targetSelector);
      var $select = $target.find('select');
      if ($select.length) {
        $select.html(data);
      } else {
        $target.html(data);
      }
    }).fail(function(){
      console.log("Ajax failed. Check if /areas route exists.");
    });
  });
}

$(document).on('turbolinks:load', initAreaSelect);
$(document).ready(initAreaSelect);
