$(document).on("keyup click", ".client_name", function(){
	if ($(this).val().length == 0) {
		defaultClientData();
	}
})

$(document).on("click","#client_name", function(){
	//evita que se autcomplete con formularios del navegador
	$(this).val("");
	$(this).attr('autocomplete', 'none');
});

$(document).on('railsAutocomplete.select', '.client-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$('input[name^="client["]').each(function(){ $(this).val("");	});
			$("input.client-autocomplete_field").val(data.item.nomatch);
		}
	}
	assignValuesToInputs(data)
	bindEnabledInputHandler()
});

function assignValuesToInputs(data) {
	let enabled_client_input = $('#client_enabled')
	let client_observation	 = $('#client_enabled_observation')

	$.each( data.item, function( key, value ) { $("#client_" + key ).val(value)	});
	enabled_client_input.prop('checked', data.item['enabled']).trigger('change')
}

function defaultClientData() {
	$(".client_iva_con").val("Responsable Inscripto");
	$(".client_document").val("80");
}

function bindEnabledInputHandler() {
	$('#client_enabled').change(function() {
		if (this.checked) {
			$(this).val('true')
			$('#client_enabled_observation').removeAttr('style')
		} else {
			$(this).val('false')
			$('#client_enabled_observation').css('border-color', 'red')
		}
		alert($(this.val()))
	})
}
