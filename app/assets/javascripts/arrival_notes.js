$(document).on('nested:fieldRemoved:arrival_note_details', function(){

})

$(document).on('pjax:complete ready', function() {

})

$(document).on('railsAutocomplete.select', '.arrival-note-autocomplete-purchase-order', function(event, data){
	params = {
		purchase_order_id: data.item.id,
		depot_id: $("#arrival_note_depot_id").val(),
		state: $("#arrival_note_state").val(),
		number: $("#arrival_note_number").val()
	}
	$.get(`${$(this).closest('form').attr("action")}/set_purchase_order`, params, null, "script");
	$("#arrival_note_purchase_order_id").val(data.item.id)

}).on('change', '.arrival-note-autocomplete-purchase-order', function(){
	if ($(this).val() == "") {
		$("#arrival_note_purchase_order_id").val("")
	}
})

$(document).on('railsAutocomplete.select', '.arrival-note-autocomplete-product', function(event, data){
	$(this).closest(".fields").find("input.product_id").val(data.item.id);
	$(this).closest(".fields").find("input.name").val(data.item.name);
});
