$(document).on('ready',function(){
  if ($('#details > tbody > tr.fields').filter(":visible").length > 0) {
    $("#editReceiptClient").attr('data-toggle', 'tooltip');
    $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
    $("#editReceiptClient").tooltip();
  }
})

$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
  $(this).closest('tr.fields').find('input.invoice_id').val(data.item.id);
	$(this).closest('tr.fields').find('input.invoice_total').val("$ " + data.item.total.toFixed(2));
  $(this).closest('tr.fields').find('input.invoice_total_left').val("$ " + data.item.total_left.toFixed(2));
  $(this).closest('tr.fields').find('input.invoice_total_pay').val("$ " + data.item.total_pay.toFixed(2));
  $(this).closest('tr.fields').find('input.invoice_created_at').val(data.item.created_at);


  $("#editReceiptClient").attr('data-toggle', 'tooltip');
  $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
  $("#editReceiptClient").tooltip();

	// var current_total = parseFloat($("#receipt_total").val())
	// $("#receipt_total").val(current_total + data.item.total)
  //
	// var no_invoices_associated = false
  //
	// $(".invoice_id").each(function(){
	// 	no_invoices_associated = $(this).val().length == 0
	// 	return no_invoices_associated
	// })
  //
	// if (!no_invoices_associated){
	// 	$('#editReceiptClient').attr("data-toggle", "");
	// 	$('#editReceiptClient').tooltip({title: "No es posible editar cliente mientras exista una factura vinculada."});
	// }

});

$(document).on('keyup','.receipt_associated-invoice-autocomplete_field', function(){
	if ($(this).val().length == 0) {
		$('#editReceiptClient').attr("data-toggle", "modal");
		$('#editReceiptClient').tooltip('dispose');
	}
})


$(document).on('click','#add_payment', function(){
  $("#total_left").empty();
  total_left = 0;
  $('#details > tbody > tr.fields').filter(":visible").each(function() {
    total_left = total_left + parseInt($(this).find('input.invoice_total_left').val());
  });

  if (total_left > 0) {
    $("#total_left").append("<p>Monto faltante a cubrir: $ " + total_left  + "</p>");
  }
})

// $(document).on('hidden.bs.modal','#clientModal', function (e) {
//   $("#receipt_client_id").trigger('change');
// })
//
// $(document).on('change','#receipt_client_id', function(){
//   $('#details > tbody > tr.fields').each(function() {
//     $(this).remove();
//   });
// })


$(document).on('nested:fieldRemoved', function(event){
  var bandera = true;
  $('#details > tbody > tr.fields').filter(":visible").each(function() {
    if ($(this).find('input.invoice_id').val() != "") {
      bandera = false;
    }
  });
  if (bandera) {
    $("#editReceiptClient").attr('data-toggle', 'modal')
                           .tooltip('dispose');
  }
	// var field 	= event.field;
	// delete_total 	= field.find("input.invoice_total").val()
	// var current_total = parseFloat($("#receipt_total").val())
  // $("#receipt_total").val(current_total - delete_total)
})
