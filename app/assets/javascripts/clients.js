$(document).on("click", "#client_name", (e) => {
	if ($(e.target).val().length == 0) { defaultClientData() }
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


$(document).ready(() =>	checkTaxes() )

$(document).on('pjax:complete', () =>	checkTaxes() )

function assignValuesToInputs(data) {
	$.each( data.item, ( key, value ) =>  $("#client_" + key ).val(value)	)
	toggleClientEnabled(data.item['enabled'])
	toggleClientValidForAccount(data.item['valid_for_account'])
	$('#invoice_client_iva_cond').val(data.item['iva_cond'])
	checkTaxes()
}

function defaultClientData() {
	$(".client_iva_con").val("Responsable Inscripto");
	$(".client_document").val("80");
}

function checkTaxes() {
	if ($('#invoice_client_iva_cond').val() == 'Consumidor Final') {
		cleanTaxes();
	}	else {
		showTaxes();
	}
}

function cleanTaxes() {
	$('#tributes tr').each( (index, current_row) => {
		$(current_row).find('[id*="_destroy"]').val(true);
		$(current_row).css('display', 'none');
	})
	$('#itaxes').css('display', 'none');
}

function showTaxes() {
	$('#itaxes').css('display', 'block');
}

function toggleClientEnabled(flag) {
	if (flag) {
		$('.client-enabled-badge').removeClass('badge-danger').addClass('badge-success').text("Habilitado")
	} else {
		$('.client-enabled-badge').removeClass('badge-success').addClass('badge-danger').text("Inhabilitado")
	}
	$('#client_enabled_flag').val(flag)
}

function toggleClientValidForAccount(onAccountFlag) {
	if (onAccountFlag) {
		$('#on_account input').removeAttr('disabled')
		$('#on_account').show()
		$('.client-account-badge').removeClass('badge-danger').addClass('badge-success').text("Cta. Cte.")
	} else {
		$('#on_account input').attr('disabled', 'disabled')
		$('#on_account').hide()
		$('.client-account-badge').removeClass('badge-success').addClass('badge-danger').text("Cta. Cte.")
	}
}
