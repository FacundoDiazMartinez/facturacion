// Toggle del menú de navegación
function toggleNav() {
  // Si el contenedor del sidebar tiene la clase 'here-i-am' significa que se está mostrando
  if ($("#nav-wrapper").hasClass("here-i-am")) {
    // Se oculta y espera al fin del efecto 'hide'
    $("#nav-wrapper").hide('fast').promise().done(function(){
      // Reducimos el contenedor del sidebar
      $("#nav-wrapper").removeAttr('class');
      $("#nav-wrapper").addClass('col-lg-0');

      // Agrandamos el contenedor del contenido principal
      $("#yield-wrapper").removeAttr('class');
      $("#yield-wrapper").addClass('col-xs-12 col-sm-12 col-md-12 col-lg-12');
    });
    // Cambiamos el ícono del boton
    $("#navButtonToggle svg").removeClass("fa-times");
    $("#navButtonToggle svg").addClass("fa-bars");
  } else {
    // Reducimos el contenedor del contenido principal
    $("#yield-wrapper").removeAttr('class');
    $("#yield-wrapper").addClass('col-md-9 col-lg-10');

    // Mostramos el sidebar y le damos tamaño apropiado
    $("#nav-wrapper").show();
    $("#nav-wrapper").removeAttr('class');
    $("#nav-wrapper").addClass('col-md-3 col-lg-2 here-i-am');

    // Cambiamos el ícono del botón
    // Cambiamos el ícono del boton
    $("#navButtonToggle svg").removeClass("fa-bars");
    $("#navButtonToggle svg").addClass("fa-times");
  }
}

function toggleSidebar() {
  if ($("#mainContent").hasClass("here-i-am")) {
    $("#mainContent").removeClass("here-i-am");
  } else {
    $("#mainContent").addClass("here-i-am");
  }
}
