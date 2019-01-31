$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
  $('#receipt_total').val(data.item.total);
  // console.log(data.item.client);
	if ($("#invoice_comp_number").val() != "") {
		$('#editReceiptClient').attr("data-toggle", "");
			$('#editReceiptClient').tooltip({title: "No es posible editar cliente mientras exista una factura vinculada."});
	}
  $('#receipt_client_name').val(data.item.client.name);
  $("#receipt_client_id").val(data.item.client.id);
  $("#invoice_client_iva_cond").val(data.item.client.iva_cond);

});

$(document).on('keyup','.receipt_associated-invoice-autocomplete_field', function(){
	if ($(this).val().length == 0) {
		$('#editReceiptClient').attr("data-toggle", "modal");
		$('#editReceiptClient').tooltip('dispose');
	}
})
