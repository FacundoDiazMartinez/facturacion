$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
	if ($("#invoice_comp_number").val() != "") {
		$('#editReceiptClient').attr("data-toggle", "");
		$('#editReceiptClient').tooltip({title: "No es posible editar cliente mientras exista una factura vinculada."});
	}
});

$(document).on('keyup','.receipt_associated-invoice-autocomplete_field', function(){
	if ($(this).val().length == 0) {
		$('#editReceiptClient').attr("data-toggle", "modal");
		$('#editReceiptClient').tooltip('dispose');
	}
})
