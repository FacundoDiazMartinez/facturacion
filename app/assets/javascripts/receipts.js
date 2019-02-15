$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
  	$(this).closest('div.fields').find('input.invoice_total').val(data.item.total);
  	$(this).closest('div.fields').find('input.invoice_id').val(data.item.id);
  	var current_total = parseFloat($("#receipt_total").val())
  	$("#receipt_total").val(current_total + data.item.total)

  	var no_invoices_associated = false

	$(".invoice_id").each(function(){
		no_invoices_associated = $(this).val().length == 0
		return no_invoices_associated
	})

	if (!no_invoices_associated){
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


$(document).on('nested:fieldRemoved', function(event){
	var field 		= event.field;
	delete_total 	= field.find("input.invoice_total").val()
	var current_total = parseFloat($("#receipt_total").val())
  	$("#receipt_total").val(current_total - delete_total)
})