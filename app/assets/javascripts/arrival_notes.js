function closePurchaseOrder(){
	$(".arrival_note_purchase_order_state").val("Finalizada");
	form = $(".arrival_note_purchase_order_state").closest('form');
	form.submit();
}

$(document).on("click", "#modal_button_an", function(){
	form = $(this).closest("form");
	if (form.valid()) {
		if ($("#arrival_note_state").val() == "Finalizado") {
			$("#purchaseOrderModal").modal("show");
		}else if ($("#arrival_note_state").val() == "Pendiente") {
			form.submit();
		}
	}else{
		form.submit();
	}
})

$(document).on('railsAutocomplete.select', '.arrival_note-purchase_order-autocomplete_field', function(event, data){
	params = {
		'purchase_order_id': data.item.id, 
		depot_id: $("#arrival_note_depot_id").val(),
		state: $("#arrival_note_state").val(),
		number: $("#arrival_note_number").val()
	}
	$.get("/arrival_notes/set_purchase_order", params, null, "script");
})


$(document).on('railsAutocomplete.select', '.arrival_note-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.purchase_order-autocomplete_field").val(data.item.nomatch);
		}
	}
  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);

		subtotal 			= $(this).closest("tr.fields").find("input.prodSubtotal");
		subtotal.trigger("change");
});
