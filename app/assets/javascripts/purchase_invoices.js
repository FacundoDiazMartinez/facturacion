$(document).on('railsAutocomplete.select', '.purchase-order-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).val(data.item.nomatch);
		}
	};
	$("#purchase_invoice_supplier_id").val(data.item.supplier_id);
	$("#purchase_invoice_total").val(data.item.total);
})