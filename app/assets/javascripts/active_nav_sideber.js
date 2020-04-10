$(document).on("ready pjax:complete", function () {
  var scope_module = window.location.pathname.split('/')[1] /// ["", "sales", "invoices"]
  $('.nav-link.active').removeClass('active');
  $(`.nav-link.${scope_module}`).addClass('active');
})
