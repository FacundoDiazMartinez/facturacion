
var checked_ids = [];

function item_checked(item_value){
  manageArray(parseInt(item_value));
  $("#sended_advertisement_clients_data").val(checked_ids.join(", ")); // Guardamos en :clients_data del formulario, el array de clientes
}

function manageArray(item_value) {
  var index = checked_ids.indexOf(parseInt(item_value));
  if (index == -1) {
    checked_ids.push(item_value);
    $('#send_button').prop('disabled', false);
  } else {
    checked_ids.splice(index, 1);
    // Si estaba seleccionado el #select_all, lo borramos del array
    if (checked_ids[0] == "all_checked") {
      checked_ids.splice(0, 1);
    }
    $('#select_all').prop('checked', false);
    if (checked_ids.length == 0) {  // Si esta todo deseleccionado deshabilitamos el boton
      $('#send_button').prop('disabled', true);
    }
  }
}

function all_checked(item_value){
  var index = checked_ids.indexOf(parseInt(item_value));
  if (index == -1) {
    $('#clients_table #client_ids').each(function(){
      $(this).prop('checked', true); //tildamos todos los checkbox de la tabla
    });
    checked_ids = []; //limpiamos el array
    $.get("/sended_advertisements/get_all_clients",{},function(data){ // Traemos los ids de TODOS los clientes sin paginar
      checked_ids = jQuery.parseJSON(data); // Ingresamos todos los clientes al array
      checked_ids.splice(0, 0,"all_checked"); // insertamos el checkbox del header

      $("#sended_advertisement_clients_data").val(checked_ids.filter(function(elem){  // Guardamos en :clients_data del formulario, el array de clientes pero sin el id del checkbox de seleccionar todos (esto no modifica el contenido del array)
          return elem != "all_checked";
        }).join(", "));
    },"script");

    $('#send_button').prop('disabled', false);
  } else {
    $('#clients_table #client_ids').each(function(){  // se destilda todo y se borran los datos del array
      $(this).prop('checked', false);
      checked_ids = [];
    });
    $("#sended_advertisement_clients_data").val(checked_ids.join(", "));

    $('#send_button').prop('disabled', true);
  }
}

function setChecked() {
  $('input:checkbox').each(function( index ) {
    if (index == 0) { // Si se trata del checkbox del header decidimos si va tildado o no
      if (checked_ids[index] == "all_checked") {
        $(this).prop('checked', true);
      } else {
        $(this).prop('checked', false);
      }
    } else { // Para todo lo demás.. existe mastercard.. na mentira, si el id del checkbox se encuentra en el array se marca como tildado
      client_id = parseInt($(this).val());
      if (checked_ids.indexOf(client_id) != -1) {
        $(this).prop('checked', true);
      }
    }
  });
};
