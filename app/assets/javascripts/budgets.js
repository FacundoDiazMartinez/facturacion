$(document).on('railsAutocomplete.select', '.budget_detail-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.autocomplete_field").val(data.item.nomatch);
		}
	}
  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);
  	$(this).closest("tr.fields").find("input.price").val(data.item.price);
  	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	$(this).closest("tr.fields").find("input.subtotal").val(data.item.price).trigger("change");


	$(this).closest("tr.fields").find("input.name").tooltip({
		title: data.item.name,
		placement: "top"
	})
});

$(document).on("change", ".subtotal", function(){
	var total = parseFloat(0);
	$(".subtotal").each(function(){
	    total = total + parseFloat($(this).val());
	});
	$("#budget_total").val(total);
	total_venta = total;
	complete_payments();
	iva_aliquot	 		= $(this).closest("tr.fields").find("select.iva_aliquot").trigger("change");
});