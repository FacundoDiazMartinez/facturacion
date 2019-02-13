
var idsArray = [];

$(document).on("change", "#client_ids", function(){
  if ($(this).is(":checked")) {
    idsArray.push($(this).val());
    $('#send_button').prop('disabled', false);
  } else {
    var index = idsArray.indexOf(parseInt($(this).val())); //obtenemos el index dentro del array del elemento que estamos destildando
    idsArray.splice(index, 1);

    // Si estaba seleccionado el #select_all, lo borramos del array
    if (idsArray[0] == "all_checked") {
      idsArray.splice(0, 1);
    }
    $('#select_all').prop('checked', false);

    if (idsArray.length == 0) {  // Si esta todo deseleccionado deshabilitamos el boton
      $('#send_button').prop('disabled', true);
    }
  }
  $("#sended_advertisement_clients_data").val(idsArray.join(", ")); // Guardamos en :clients_data del formulario, el array de clientes
})

$(document).on("change", "#select_all", function(){
  if ($(this).is(":checked")) {
    $('#clients_table #client_ids').each(function(){
      $(this).prop('checked', true); //tildamos todos los checkbox de la tabla
    });


    idsArray = []; //limpiamos el array
    $.get("/sended_advertisements/get_all_clients",{},function(data){ // Traemos los ids de TODOS los clientes sin paginar
      idsArray = jQuery.parseJSON(data); // Ingresamos todos los clientes al array
      idsArray.splice(0, 0,"all_checked"); // insertamos el checkbox del header

      $("#sended_advertisement_clients_data").val(idsArray.filter(function(elem){  // Guardamos en :clients_data del formulario, el array de clientes pero sin el id del checkbox de seleccionar todos (esto no modifica el contenido del array)
          return elem != "all_checked";
        }).join(", "));
    },"script");

    $('#send_button').prop('disabled', false);
  } else {
    $('#clients_table #client_ids').each(function(){  // se destilda todo y se borran los datos del array
      $(this).prop('checked', false);
      idsArray = [];
    });
    $("#sended_advertisement_clients_data").val(idsArray.join(", "));

    $('#send_button').prop('disabled', true);
  }
})
