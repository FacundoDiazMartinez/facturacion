$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
  $('#receipt_total').val(data.item.total);
	if ($("#invoice_comp_number").val() != "") {
		$('#editReceiptClient').attr("data-toggle", "");
			$('#editReceiptClient').tooltip({title: "No es posible editar cliente mientras exista una factura vinculada."});
	}
  // $('#receipt_client_name').val('<%= Invoice.find(1).client.name %>');
  // $("#receipt_client_id").val("<%= @client.id %>");
});

$(document).on('keyup','.receipt_associated-invoice-autocomplete_field', function(){
	if ($(this).val().length == 0) {
		$('#editReceiptClient').attr("data-toggle", "modal");
		$('#editReceiptClient').tooltip('dispose');
	}
})
