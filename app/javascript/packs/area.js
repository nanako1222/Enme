/*global $*/
//$(document).on('turbolinks:load',function(){
$(function(){
  $('#customer_state_id').change(function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "customer",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select_customer').html(data)
    })
  })
// });

//$(document).on('turbolinks:load',function(){
// $(function(){
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

  $('#admin_state_id').change(function() {
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

  $('#admin_state_id').change(function() {
    $.ajax('/areas', {
      type: 'GET',
      data: {
        type: "customer",
        state_id: $(this).val()
      }
    }).done(function(data){
      $('#areas_select_customer').html(data)
    })
  })
});
