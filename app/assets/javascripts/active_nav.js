function initializeActiveNav(active_list_item) {
  $('.nav-view-item.active').removeClass("active");
  $(`.nav-view-item.${active_list_item}`).addClass("active");
}
