$(document).on('railsAutocomplete.select', '.delivery_note-autocomplete_field', function(event, data){
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


function closeDeliveryNote(){
	$("#delivery_note_state").val("Finalizado");
	form = $("#delivery_note_state").closest('form');
	form.submit();
}

$(document).on('railsAutocomplete.select', '.delivery_note_associated-invoice-autocomplete_field', function(event, data){
	params = {
		associated_invoice_id: data.item.id,
		date: $("#delivery_note_date").val(),
		state: $("#delivery_note_state").val(),
		number: $("#delivery_note_number").val()
	}
	form = $(this).parents('form:first');
	$.get(form.attr("action")+'/set_associated_invoice', params, null, "script");
	if ($("#invoice_comp_number").val() != "") {
		$('#editClient').attr("data-toggle", "");
			$('#editClient').tooltip({title: "No es posible editar cliente mientras exista una factura vinculada."});
	}
});

$(document).on('keyup','.delivery_note_associated-invoice-autocomplete_field', function(){
	if ($(this).val().length == 0) {
		$('#editClient').attr("data-toggle", "modal");
		$('#editClient').tooltip('dispose');
	}
})

// $(document).on('click', '.input-group-text',function(e){
// 	e.preventDefault();
// 	if ($("#invoice_comp_number").val() != "") {
// 		alert("AD")
// 		$(this).attr("data-toggle", "")
// 		return false;
// 	}
// });

$(document).on("click", "#modal_button_dn", function(){
	form = $(this).closest("form");
	if (form.valid()) {
		$("#deliveryNoteModal").modal("show");
	}else{
		form.submit();
	}
})


$(document).on("ready", function(){
	$("button[type='submit']").on("click", function(e){
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
