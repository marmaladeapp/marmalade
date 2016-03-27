//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//
//= require foundation-sites
//
//= require jstz.min
//= require countries.min
//
//= require shared/flippable
//
//= require turbolinks

Turbolinks.enableProgressBar();
$(function() {
  $(document).foundation();
});


$(document).ready(function() {
  $(".plan-select").click(function() {
    slug = $(this).attr("data-slug");
    $("#user_plan_id").val(slug);
  });
});