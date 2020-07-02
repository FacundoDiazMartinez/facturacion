var invoiceTotal = 0
var invoiceLeft  = 0
var COD_ND 			 = ["02", "07", "12"]
var COD_NC 			 = ["03", "08", "13"]
var COD_IVA			 = ["01", "11"]

function initializeInvoice() {
	runDetails()
	runPayments()

	checkNotaDebito()
}

$(document).on("change", "#invoice_cbte_tipo", function() {
	checkNotaDebito()
})

$(document).on('nested:fieldAdded:invoice_details', function(event){
  checkNotaDebito();
});

$(document).on("change", "#invoice_cbte_tipo, #invoice_concepto", function(){
	if ($.inArray($(this).val(), COD_NC) > -1 ) {
		$("#payment_title").html("Devoluciones de dinero");
	}else{
		$("#payment_title").html("Pagos");
	}

	form = $(this).parents('form:first');
	cbte_tipo = $("#invoice_cbte_tipo");
	concepto = $("#invoice_concepto");
	$.get(form.attr("action")+'/change_attributes', { cbte_tipo: cbte_tipo.val(), concepto: concepto.val() }, null, "script");
});

$(document).on('railsAutocomplete.select', '.associated-invoice-autocomplete_field', function(event, data){
	if (COD_ND.indexOf($("#invoice_cbte_tipo").find('option:selected').val()) == -1) {
		getAssociatedInvoice($("#invoice_associated_invoice").val())
	}
});

function runInvoice(){
	var data = {
		invoice_details_attributes: [],
		bonifications_attributes: [],
		tributes_attributes: []
	}

	$("#details > tbody > tr.fields").each((index, currentField) => {
    setDetailRowVars($(currentField));
    if (activo) {
			let invoice_detail_data = {
				precio: price.val(),
				cantidad: quantity.val(),
				bonificacion: bonus_percentage.val(),
				iva: iva_aliquot.val(),
				subtotal: subtotal.val()
			}
			data['invoice_details_attributes'].push(invoice_detail_data)
    }
  })
	$("#bonifications > tbody > tr").each((index, element) => {
    setBonificationRowVars($(element))
    if (activo && alicuota.val()) {
			let bonifications_data = { alicuota: alicuota.val() }
      data['bonifications_attributes'].push(bonifications_data)
    }
  })
	$('#tributes > tbody > tr').each((index, currentField) => {
    setTaxesRowVars($(currentField))
    if (activo) {
			let tributes_data = { alicuota: alicuotaTax.val() }
			data['tributes_attributes'].push(tributes_data)
    }
  })

	if (data['invoice_details_attributes'].length > 0) {
		fetch('/sales/invoices/calculate_invoice_totals', {
			method: 'POST',
			body: JSON.stringify(data),
			headers: {
				'Content-Type': 'application/json'
			}
		})
		.then(response => response.json())
		.then((details) => {
			invoiceTotal = details['detalles']['total_venta']

			$('.total_details').text(details['detalles']['importe_neto'].toFixed(2))
			$('.detail_iva').text(details['detalles']['importe_iva'].toFixed(2))

			totalDetalles    = details['detalles']['importe_neto']
			totalDetallesIVA = details['detalles']['importe_iva']

			$(".final_total").text(invoiceTotal.toFixed(2))
			$("#invoice_total").val(invoiceTotal.toFixed(2))

			pagos				= parseFloat(getTotalPayments().toFixed(2))
			invoiceLeft = parseFloat(details['detalles']['total_venta']) - pagos

			$(".total_payments_left").text(invoiceLeft.toFixed(2))
			$("#total_left").val(invoiceLeft.toFixed(2))
		})
		.catch(function(err) {
			console.log(err);
		});
	}
}

function setConfirmParam(){
	if ($("#invoice_client_name").closest('form').valid()) {
		$("#confirm_invoice_button").attr('disabled', 'disabled');
		$("#confirm_invoice_button").text("Cargando...");
	};
	$("#send_to_afip").prop('checked', true);
	$("#send_to_afip").closest('form').submit();
}

function openConfirmationModal(){
	//carga la modal de advertencia antes de confirmar y la muestra
	runInvoice()
	$('#client_name_modal').text($('#invoice_client_name').val())
	$('#doc_type_modal').text($('#invoice_cbte_tipo option:selected').text())
	$('#invoice_total_modal').text("$ " + invoiceTotal.toFixed(2))
	$('#invoice_total_pay_modal').text("$ " + $('.total_payments').first().text())
	$('#invoice_total_left_modal').text("$ " + invoiceLeft.toFixed(2))
	iva = $('.detail_iva').first().text() - $('.total_details').first().text()
	$('#confirmation_subtotal').text("$ " + $('.total_details').first().text())
	$('#confirmation_subtotal_iva').text("$ " + iva.toFixed(2))
	$('#confirmation_bonifications').text("-$ " + $('.total_bonifications').first().text())
	$('#confirmation_taxes').text("$ " + $('.total_tributes').first().text())

	//$('#confirm_invoice_modal').modal('toggle');
	$('#confirm_invoice_modal').modal('show');
}

function checkNotaDebito() { if (COD_ND.indexOf($("#invoice_cbte_tipo").val()) != -1) { blockDetailsForDebitNote() } }

function getTipoIVA() {	return COD_IVA.indexOf($("#invoice_cbte_tipo").val()) != -1 }

function changeView(tipo){
	$("#view").val(tipo).trigger("change");
};

function toggleHeader(){
	var display = $(".invoice-header").css('display');
	if (display == 'flex'){
		$(".invoice-header").hide('fast');
		$("#toggle_header").html("").append($("<i class='fa fa-eye'></i>")).button();
		$("#toggle_header").append(' Encabezado');
	}
	else{
		$(".invoice-header").show('fast');
		$("#toggle_header").html("").append($("<i class='fa fa-eye-slash'></i>")).button();
		$("#toggle_header").append(' Encabezado');
	}
}

function toggleAuthorized(){
	var display = $("#div_iauthorized").css('display');
	if (display == 'none'){
		$("#div_iauthorized").show('fast');
		$([document.documentElement, document.body]).animate({
      scrollTop: $("#div_iauthorized").offset().top - 100,
    }, 500, function(){
    	$("#div_iauthorized").effect( "shake" );
    });
	} else {
		$("#div_iauthorized").hide('fast');
	}
}

$(document).on("railsAutocomplete.select", "#invoice_associated_invoice", function(){

	getAssociatedInvoice(invoice)
})

const getAssociatedInvoice = (invoice) => {
	$.get(`/sales/invoices/${invoice}/get_associated_invoice_details`, (response) => {
		response.map( (item, index) => {
			let tr = $('table#details > tbody > tr:last-child')
			if (tr.find("[id$=product_attributes_code]").val() != null){
				const link = $('.add_nested_fields[data-target="#details"]');
				link.click();
				let tr = $('table#details > tbody > tr:last-child')
			}

			tr.find("[id$=product_attributes_code]").val(item.product_attributes.code);
			tr.find("[id$=product_attributes_name]").val(item.product_attributes.name);
			tr.find("[id$=_price_per_unit]").val(item.price_per_unit);
			tr.find("[id$=quantity]").val(item.quantity);
			tr.find("[id$=depot_id]").val(item.depot_id);
			tr.find("[id$=measurement_unit]").val(item.measurement_unit);
			tr.find("[id$=bonus_amount]").val(item.bonus_amount);
			tr.find("[id$=iva_aliquot]").val(item.iva_aliquot).trigger("change");
			tr.find("[id$=iva_amount]").val(item.iva_amount);
		})

	})
}
