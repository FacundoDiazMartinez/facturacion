$(document).on("click", "#client_name", (e) => {
	if ($(e.target).val().length == 0) {
		defaultClientData()
	}
	$(e.target).val("")
})

$(document).on('railsAutocomplete.select', '.client-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined') {
		if (data.item.nomatch.length) {
			$('input[name^="client["]').each( () => $(this).val("") )
			$("input.client-autocomplete_field").val(data.item.nomatch)
		}
	}
	assignValuesToInputs(data)
});

function assignValuesToInputs(data) {
	$.each( data.item, ( key, value ) =>  $("#client_" + key ).val(value)	)
	toggleClientEnabled(data.item['enabled'])
	toggleClientValidForAccount(data.item['valid_for_account'])
	if (data.item['iva_cond'] == 'Consumidor Final') {
		cleanTributes();
	};
}

$( document ).ready(function() {
	if ($('#invoice_client_iva_cond').val() == 'Consumidor Final') {
		cleanTributes();
	}
	else{
		getTotalTaxes();
	}
})

function defaultClientData() {
	$(".client_iva_con").val("Responsable Inscripto");
	$(".client_document").val("80");
}

function cleanTributes() {
	$('#tributes tr').each( (index, current_row) => {
		$(current_row).find('[id*="_destroy"]').val(true);
		$(current_row).css('display', 'none');
	})
	$('#tributes_wrapper').css('display', 'none');
}
function showTributes() {
	$('#tributes tr').each( (index, current_row) => {
		$(current_row).find('[id*="_destroy"]').val(true);
		$(current_row).css('display', 'none');
	})
	$('#tributes_wrapper').css('display', 'none');
}

function toggleClientEnabled(flag) {
	if (flag) {
		$('.client-enabled-badge').removeClass('badge-danger').addClass('badge-success').text("Habilitado")
	} else {
		$('.client-enabled-badge').removeClass('badge-success').addClass('badge-danger').text("Inhabilitado")
	}
	$('#client_enabled_flag').val(flag)
}

function toggleClientValidForAccount(flag) {
	if (flag) {
		$('.client-account-badge').removeClass('badge-danger').addClass('badge-success').text("Cta. Cte.")
	} else {
		$('.client-account-badge').removeClass('badge-success').addClass('badge-danger').text("Cta. Cte.")
	}
}
