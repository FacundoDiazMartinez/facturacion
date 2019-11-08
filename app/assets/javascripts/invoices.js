var invoiceTotal = 0
var invoiceLeft  = 0
var COD_ND 			 = ["02", "07", "12"]
var COD_NC 			 = ["03", "08", "13"]
var COD_IVA			 = ["01", "11"]

function initializeInvoice() {
	runDetails()
	runPayments()

  runInvoice();

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
		form = $(this).parents('form:first');
		$.get(form.attr("action")+'/set_associated_invoice', {associated_invoice: $(this).val()}, null, "script");
	}
});

function runInvoice(){
	conceptos 	= parseFloat(getTotalDetails().toFixed(2))
	descuentos	= parseFloat(getTotalBonificationsIVA().toFixed(2))
	impuestos		= parseFloat(getTotalTaxes().toFixed(2))
	pagos				= parseFloat(getTotalPayments().toFixed(2))

	invoiceTotal = parseFloat((conceptos - descuentos + impuestos).toFixed(2))
	invoiceLeft  = parseFloat((invoiceTotal - pagos).toFixed(2))

	$(".final_total").text(invoiceTotal.toFixed(2))
	$("#invoice_total").val(invoiceTotal.toFixed(2))
	$(".total_payments_left").text(invoiceLeft.toFixed(2))
	$("#total_left").val(invoiceLeft.toFixed(2))
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

function addRechargeToDetails(){
	var recharge = parseFloat($("#client_recharge").val() * -1);
	$("input.bonus_percentage").each(function() {
		$(this).val(recharge).trigger("change");
	})
}

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
