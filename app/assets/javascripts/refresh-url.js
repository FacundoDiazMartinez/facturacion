// requires jQuery
$(document).on("ready pjax:complete", function() {
  bindRefreshHandlers();
  $(window).on("popstate", function (e) { location.reload(); });
});


function bindRefreshHandlers() {
  // asigna el método a los elementos a con data-remote=true, omite modales
  $('a[data-remote="true"]:not([data-toggle="modal"], [data-refresh="false"])').on('click', (e) => {
    e.preventDefault();
    // extrae el attr href de los links
    refreshURL(e.target.href)
  });
  // asigna el método a los elementos de la paginación
  $('ul.pagination a').on('click', (e) => {
    e.preventDefault();
    refreshURL(e.target.href)
  });
};
function refreshURL(url) {
  // reemplaza el estado del historial
  window.history.replaceState(null, "", url);
}
