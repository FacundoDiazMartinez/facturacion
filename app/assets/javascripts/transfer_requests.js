function sendTransferRequest(){
	$("#transfer_request_state").val("Enviado");
	form = $("#transfer_request_state").closest('form');
	form.submit();
}

function closeTransferRequest(){
	$("#transfer_request_state").val("Finalizado");
	form = $("#transfer_request_state").closest('form');
	form.submit();
}

$(document).on('railsAutocomplete.select', '.transfer_request-autocomplete_field', function(event, data){
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


$(document).on("click", "#modal_button_tr", function(){
	form = $(this).closest("form");
	if (form.valid()) {
		$("#transferRequestModal").modal("show");
	}else{
		form.submit();
	}
})


$(document).on("ready", function(){
	$("#transfer_request_submit").on("click", function(e){
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
