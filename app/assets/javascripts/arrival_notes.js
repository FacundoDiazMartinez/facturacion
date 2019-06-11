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

$(document).on('nested:fieldRemoved:arrival_note_details', function(){
	disable_purchase_order_id();
})

function disable_purchase_order_id(){
	if ($("#details > tbody > tr:visible").length > 0) {
		$("#purchase_order_id").attr("readonly",true);
	}else {
		$("#purchase_order_id").attr("readonly",false);
	}
}

$(document).on('pjax:complete', function() {
	disable_purchase_order_id();
})

$( document ).ready(function() {
	disable_purchase_order_id();
})

$(document).on('railsAutocomplete.select', '.arrival_note-purchase_order-autocomplete_field', function(event, data){
	params = {
		purchase_order_id: data.item.id,
		depot_id: $("#arrival_note_depot_id").val(),
		state: $("#arrival_note_state").val(),
		number: $("#arrival_note_number").val()
	}
	form = $(this).parents('form:first');
	$.get(form.attr("action") + "/set_purchase_order", params, null, "script");
	$(this).attr("disabled",true);
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
