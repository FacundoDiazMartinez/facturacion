function closePurchaseOrder(){
	$(".arrival_note_purchase_order_state").val("Finalizada");
	form = $(".arrival_note_purchase_order_state").closest('form');
	form.submit();
}

$(document).on("click", "#modal_button_an", function(){
	form = $(this).closest("form");
	if (form.valid()) {
		$("#purchaseOrderModal").modal("show");
	}else{
		form.submit();
	}
})

$(document).on('railsAutocomplete.select', '.arrival_note-purchase_order-autocomplete_field', function(event, data){
	$.get("/arrival_notes/set_purchase_order", {'purchase_order_id': data.item.id}, null, "script");
	$("#purchase_order_number").html(data.item.value);
	$(".arrival_note_purchase_order_state").val(data.item.state);
})
