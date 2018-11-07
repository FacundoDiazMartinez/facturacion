$(document).on("change", "#arrival_note_purchase_order_id", function(){
	$.get("/arrival_notes/set_purchase_order", {'purchase_order_id': $(this).val()}, null, "script");
});