$(document).on('railsAutocomplete.select', '.delivery_note-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest(".fields").find("input.delivery_note-autocomplete_field").val(data.item.nomatch);
		}
	}
	$(this).closest(".fields").find("input.product_id").val(data.item.id);
	$(this).closest(".fields").find("input.name").val(data.item.name);
	$(this).closest(".fields").find("input.prodSubtotal").trigger("change");
});

$(document).on('railsAutocomplete.select', '.delivery_note_associated-invoice-autocomplete_field', function(event, data){
	params = {
		associated_invoice_id: data.item.id,
		date: $("#delivery_note_date").val(),
		state: $("#delivery_note_state").val(),
		number: $("#delivery_note_number").val()
	}
	form = $(this).closest("form");

	setDeliveryNoteDetailsFromInvoice(form);
	$('#delivery_note_client_name').val(data.item.client.name);
  $("#delivery_note_client_id").val(data.item.client.id);
  $("#delivery_note_client_iva_cond").val(data.item.client.iva_cond);
	$("#delivery_note_invoice_id").val(data.item.id.toString())
	console.log(data.item.id)
});

$(document).on("click", "#modal_button_dn", function(){
	form = $(this).closest("form");
	if (form.valid()) {
		$("#deliveryNoteModal").modal("show");
	}else{
		form.submit();
	}
})

$(document).on("ready", function(){
	$("#save_btn_receipt, #confirm_btn").on("click", function(e){
		$(this).valid()
	});
	jQuery.validator.setDefaults({
	    errorPlacement: function (error, element) {
	    	$(element).attr("data-toggle", "tooltip").attr("data-placement", "top").attr("title", error.text()).tooltip('show')
	    },
	    unhighlight: function (element) {
	       $(element).removeClass('is-invalid').addClass('is-valid');
	    },
	    highlight: function (element) {
	        $(element).removeClass('is-valid').addClass('is-invalid');
	    }
	});

});

function setDeliveryNoteDetailsFromInvoice(form) {
	$.get(form.attr("action")+'/set_associated_invoice', params, null, "script");
}
