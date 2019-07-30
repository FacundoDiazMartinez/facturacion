$(document).on('railsAutocomplete.select', '.client-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$('input[name^="client["]').each(function(){
			    $(this).val("");
			});
			$("input.client-autocomplete_field").val(data.item.nomatch);
		}
	}
	$.each( data.item, function( key, value ) {
	  $("#client_"+key).val(value);
	});
	$('#client_enabled').prop('checked', data.item['enabled']);
	$('#client_enabled_observation').prop('disabled', data.item['enabled']);
});

$(document).on("keyup click", ".client_name", function(){
	if ($(this).val().length == 0) {
		$(".client_iva_con").val("Responsable Inscripto");
		$(".client_document").val("80");
	}
})

