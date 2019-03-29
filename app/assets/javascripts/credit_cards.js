$(document).on('pjax:complete', function() {
  hideCardName();
})

$(document).on('ready', function(){
  hideCardName();
})

function hideCardName(){
  if ($('#credit_card_fav_logo :selected').val() != "credit-card") {
    $('#credit_card_name').val($("#credit_card_fav_logo :selected").text());
    $('#credit_card_name').attr('readonly', true);
    $('#credit_card_name_div').hide();
    $('#logo_div').removeAttr("hidden");
  }
}

$(document).on('change', '#credit_card_type_of_fee', function(){
  if ($(this).val() == "Coeficiente") {
    $('#fees > tbody > tr.fields').each(function() {
      $(this).find('input.tna').removeAttr('readonly');
      $(this).find('input.tem').removeAttr('readonly');
      $(this).find('input.coefficient').removeAttr('readonly');
      $(this).find('input.percentage').attr('readonly', 'true');
    });
  } else {
    $('#fees > tbody > tr.fields').each(function() {
      $(this).find('input.tna').attr('readonly', 'true');
      $(this).find('input.tem').attr('readonly', 'true');
      $(this).find('input.coefficient').attr('readonly', 'true');
      $(this).find('input.percentage').removeAttr('readonly');
    });
  }
})


$(document).on('nested:fieldAdded', function(event){
  cantidad_filas = $('#fees > tbody > tr.fields:visible').length;
  if (cantidad_filas == 1) {  //Porque al agregar fila, primero se agrega fila y luego corre este código
    last_value = 0;
  } else {
    last_value = $('#fees > tbody > tr:visible:eq(' + (parseInt(cantidad_filas) - 2) + ')').find('input.quantity').val();  //porque la primera fila tiene index = 0 y se quita la nueva fila que se agregó
  }

  // last_value = $('#fees > tbody > tr:visible:last').prev("tr").find('input.quantity').val();

  if (last_value > 1) { // quiere decir que sólo si había al menos una fila antes de agregar una nueva, vamos a buscar el último valor de cantidad de cuotas
    event.field.find('input.quantity').val(parseInt(last_value)+1);
  }
  if ($('#credit_card_type_of_fee').val() == "Coeficiente") {
    event.field.find('input.tna').removeAttr('readonly');
    event.field.find('input.tem').removeAttr('readonly');
    event.field.find('input.coefficient').removeAttr('readonly');
    event.field.find('input.percentage').attr('readonly', 'true');
  } else {
    event.field.find('input.tna').attr('readonly', 'true');
    event.field.find('input.tem').attr('readonly', 'true');
    event.field.find('input.coefficient').attr('readonly', 'true');
    event.field.find('input.percentage').removeAttr('readonly');
  }
})

$(document).on('change', '#credit_card_fav_logo', function(){
  if ($(this).val() == "credit-card") {
    $('#credit_card_name').val("");
    $('#credit_card_name').attr('readonly', false);
    $('#logo_div').hide();
    $('#credit_card_name_div').show("slow");
  } else {
    $('#credit_card_name').val($("#credit_card_fav_logo :selected").text() );
    $('#credit_card_name').attr('readonly', true);
    $('#credit_card_name_div').hide();


    $('#logo_div').hide();
    $("#logo_div").find("i").attr('class', 'fab fa-' + $("#credit_card_fav_logo :selected").val());
    $('#logo_div').removeAttr("hidden");
    $('#logo_div').show("slow");
  }
})

$(document).on('change', '#transfer_to', function(){
  if ($(this).val() == "Cuenta Bancaria"){
    $("#bank_group").show();
  }else{
    $("#bank").val("")
    $("#bank_group").hide();
  }
})
