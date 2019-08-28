var total_venta = parseFloat(0);
var rest 				= parseFloat(0);
var index 			= {};
var total_left 	= parseFloat(0);
var COD_INVOICE = ["01", "06", "11"]
var COD_ND 			= ["02", "07", "12"];
var COD_NC 			= ["03", "08", "13"];

$(document).ready(function() {
	autocomplete_product_field();
	if ($("#invoice_total").val() > 0) {
		total_venta = parseFloat($("#invoice_total").val());
	}
	if ($("#purchase_order_total").val() > 0) {
		total_venta = parseFloat($("#purchase_order_total").val());
	}
	showProductNamePopover();
	hideAgregarConceptoButton();
	$("input.price").trigger("change");
});

$(document).on('pjax:complete', function() {
	showProductNamePopover();
	hideAgregarConceptoButton();
	$("input.price").trigger("change");
});

function hideAgregarConceptoButton(){
	if ($.inArray($("#invoice_cbte_tipo").val(), COD_NC) > -1) {
		$("#add_concept_to_invoice").hide();
		$("#invoice_cbte_tipo").attr("readonly","readonly");
	}
}

function showProductNamePopover() {
	$("#details tr.fields").each(function(){
		var name = $(this).find(".name");
		name.popover({
			title: "Concepto",
			trigger: "hover",
			content: name.val(),
		});

		var iva = $(this).find(".iva_aliquot");
		var iva_amount = $(this).find("input.iva_amount").val();
		iva.popover({
			title: "Monto I.V.A.",
			trigger: "hover",
			content: `$ ${iva_amount}`
		});
	});
}

function setConfirmParam() {
	if ($("#invoice_client_name").closest('form').valid()) {
		$("#confirm_invoice_button").attr('disabled', 'disabled');
		$("#confirm_invoice_button").text("Cargando...");
	};
	$("#send_to_afip").prop('checked', true);
	$("#send_to_afip").closest('form').submit();
}

function openConfirmationModal () {  //carga la modal de advertencia antes de confirmar y la muestra
	$('#client_name_modal').val($('#invoice_client_name').val());
	$('#doc_type_modal').val($('#invoice_cbte_tipo option:selected').text());
	$('#invoice_total_modal').val('$ ' + $('#invoice_total').val());
	$('#invoice_total_pay_modal').val('$ ' + $('#invoice_total_pay').val());

	//$('#confirm_invoice_modal').modal('toggle');
	$('#confirm_invoice_modal').modal('show');
}

function updateTooltip22(element) {
	var iva_amount = element.closest("td").find("input.iva_amount").val();
	$(element).popover('dispose');
	$(element).popover({
		title: "Monto I.V.A.: $ " + iva_amount,
		trigger: "hover"
	});
}

$(document).on('railsAutocomplete.select', '.invoice-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.autocomplete_field").val(data.item.nomatch);
		}
	}

	var recharge = parseFloat($("#client_recharge").val() * -1);

	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
	$(this).closest("tr.fields").find("input.name").val(data.item.name).popover('dispose').popover({
		title: data.item.name,
		trigger: "hover"
	});
	$(this).closest("tr.fields").find("select.tipo").val(data.item.tipo);

	$(this).closest("tr.fields").find("input.price").val(data.item.price);
	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	$(this).closest("tr.fields").find("input.subtotal").val(data.item.price);
	$(this).closest("tr.fields").find("input.quantity").val(1);


	$(this).closest("tr.fields").find("select.depot_id > option").each(function(ind){    //  >> Limpiamos los nombres de los depósitos por si no es un tr nuevo
		if (ind > 0) {
			name_to_clean = $(this).text();
			i = name_to_clean.indexOf(" [ Stock");
			if (i >= 0) {
				depot_name = jQuery.trim(name_to_clean).substring(0, i);
				$(this).text(depot_name);
			}
		}
	});

	current_trow = $(this).closest("tr.fields");

	data.item.depots_with_quantities.forEach(function(depot){				//  >> Añadimos cantidades en los nombres de los depósitos
		current_trow.find("select.depot_id > option").each(function(i){
			if (i > 0) {
				option = $(this);
				if (depot.depot_id == option.val()) {
					depot_name = option.text();
					option.text(depot_name + " [ Stock: " + depot.quantity + " ]");
				}
			}
		});
	});

	if (data.item.tipo == "Servicio") {
		$(this).closest("tr.fields").find("select.depot_id").attr("disabled", true);
	} else {
		$(this).closest("tr.fields").find("select.depot_id > option").each(function(){
			if ($(this).val() == data.item.best_depot_id) {
				$(this).closest("tr.fields").find("select.depot_id").val(data.item.best_depot_id);
			}
		});
	}

	$(this).closest("tr.fields").find("select.iva_aliquot").val(data.item.iva_aliquot);
	$(this).closest("tr.fields").find("input.bonus_percentage").val(recharge).trigger("change");
	// calculateInvoiceDetailSubtotal($(this).closest("tr.fields").find("input.subtotal"));
});

function setVars(current_field){
	price							= current_field.closest("tr.fields").find("input.price");
	subtotal 					= current_field.closest("tr.fields").find("input.subtotal");
	quantity 					= current_field.closest("tr.fields").find("input.quantity");
	bonus_percentage 	= current_field.closest("tr.fields").find("input.bonus_percentage");
	bonus_amount			= current_field.closest("tr.fields").find("input.bonus_amount");
	iva_amount				= current_field.closest("tr.fields").find("input.iva_amount");
	iva_aliquot	 			= current_field.closest("tr.fields").find("select.iva_aliquot").find('option:selected');
}

$(document).on("change", ".price, .quantity, .bonus_percentage", function(){
	setVars($(this));

	total_neto 					= parseFloat(price.val()) * parseFloat(quantity.val());
	bonification_amount = (total_neto * (parseFloat(bonus_percentage.val()) / 100)).toFixed(2);
	bonus_amount.val(bonification_amount);
	calculateInvoiceDetailSubtotal(subtotal);
});

$(document).on("change", ".bonus_amount", function(){
	setVars($(this));

	total_neto 				= parseFloat(price.val()) * parseFloat(quantity.val());
	b_percentage 		= (parseFloat(bonus_amount.val()) * 100 / parseFloat(total_neto)).toFixed(2);
	bonus_percentage.val(b_percentage);
	calculateInvoiceDetailSubtotal(subtotal);
});

$(document).on("change", ".iva_aliquot", function(){
	setVars($(this));

	(iva_aliquot.val() == "01" || iva_aliquot.val() == "02") ? (iva_am = 0.0) : (iva_am = ( (price.val() - bonus_amount.val() ) * parseFloat( iva_aliquot.text() ) * quantity.val() ).toFixed(2));

	iva_amount.val(iva_am);
	updateTooltip22($(this));
	calculateInvoiceDetailSubtotal(subtotal);
});

function calculateInvoiceDetailSubtotal(subtotal){
	setVars(subtotal);
	if (iva_aliquot.val() == "01" || iva_aliquot.val() == "02") {
		iva_am = 0.0
	}else{
		iva_am = (((price.val() * quantity.val()) - bonus_amount.val()) * parseFloat(iva_aliquot.text())).toFixed(2);
	}
	iva_amount.val(iva_am);
	var sTotal = ((parseFloat(price.val())  * parseFloat(quantity.val()) ) + parseFloat(iva_amount.val()) - parseFloat(bonus_amount.val())).toFixed(2)
	subtotal.val(sTotal);

	calculateTotalOfInvoice();  // >>>>>>>>>>>  Impacto sobre el resto de la factura

	subtotal.closest("td").find("strong").html("$ " + subtotal.val());
}

function calculateNeto(){
	let total_neto = 0;
	$("#details > tbody > tr:visible").each(function() { // >>>>>>>>>>>>>>>>>>>>>>>>> Suma de subtotales de cada concepto [SIN IVA]
		let precio 				= $(this).find("input.price").val() * $(this).find("input.quantity").val();
		let descuento 		= precio * ($(this).find("input.bonus_percentage").val() / 100);

		total_neto 				+= precio - descuento; // >> Subtotal sin IVA
	});
	return total_neto;
}

function calculateNetoConDescuentos(){
	let total_neto 				= calculateNeto();
	let bonifications_iva = parseFloat(0);
	$("#bonifications > tbody > tr").each(function() {
		if ($(this).css('display') != 'none') {
			let monto 				= parseFloat($(this).find("input.bonif_amount").val());
			let percentage		= parseFloat($(this).find("input.bonif_percentage").val());
			bonifications_iva += monto;
			total_neto 				-= total_neto * (percentage / 100);
		}
	});
	$('.total_bonifications').text(bonifications_iva.toFixed(2));
	return total_neto;
}

function calculateTotalOfInvoice(){
		let inv_total 	= parseFloat(0);
		let iva_am 			= parseFloat(0);
		let neto_puro 	= calculateNeto();
		let total_neto 	= calculateNetoConDescuentos();
		let tributos		= parseFloat(0);

		$("tr.fields:visible > td > input.subtotal").each(function() {
			inv_total += parseFloat($(this).val());
		});
		$("tr.fields:visible > td > input.iva_amount").each(function() {
			iva_am += parseFloat($(this).val());
		});

		$(".total_details").text(neto_puro.toFixed(2));
		$(".total_iva").text(iva_am.toFixed(2));
		$(".detail_iva").text(inv_total.toFixed(2));

		$("#bonifications > tbody > tr").each(function(){ // >>>>>>>>>>>>>>>>>>>>>>>>> Descuentos NESTED al total
			if ($(this).css('display') != 'none') {
				percentage = $(this).find($("input.bonif_percentage")).val();
				$(this).find($("input.bonif_subtotal")).val((inv_total * ((100 - percentage) / 100)).toFixed(2));
				$(this).find($("input.bonif_amount")).val((inv_total * (percentage / 100)).toFixed(2));
				inv_total 				-= (inv_total * (percentage / 100)).toFixed(2);
			}
		});

		$("#tributes > tbody > tr").each(function(){ // >>>>>>>>>>>>> Cálculo de tributos en base a suma de subtotales sin iva y descuentos aplicados
			if ($(this).css('display') != 'none') {
				base_imp 	= total_neto.toFixed(2);
				e 				= $(this).find("input.base_imp");
				e.val(base_imp);
				alic 	 		= parseFloat(e.closest("tr.fields").find("input.alic").val());
				importe 	= (base_imp * (alic/100)).toFixed(2);
				e.closest("tr.fields").find("input.importe").val(importe);
				inv_total += parseFloat(importe);
				tributos	+= parseFloat(importe);
			}
		})

		$('.total_tributes').text(tributos.toFixed(2));

		$("#invoice_total").val(inv_total.toFixed(2));
		$(".final_total").text(inv_total.toFixed(2));

		total_left = inv_total.toFixed(2) - parseFloat($("#invoice_total_pay").val()).toFixed(2);
		total_pay = parseFloat($("#invoice_total_pay").val());
		$("#invoice_total_pay").val(total_pay.toFixed(2));
		$("#total_left").val(total_left.toFixed(2));
		$("#total_left_invoice").text("Total faltante: \xa0 \xa0 \xa0 $" + total_left.toFixed(2));
		$("#total_left_venta").text("$" + total_left.toFixed(2));

		$(".total_payments").text(total_pay.toFixed(2));
		$(".total_payments_left").text(total_left.toFixed(2));

		if ($("#invoice_cbte_tipo").length != 0) {
			var is_invoice = $.inArray($("#invoice_cbte_tipo").val(), COD_INVOICE )
			if (total_left > 0 || is_invoice < 0) {
				$("#normal").show();
				$("#with_alert").hide();
			} else {
				$("#normal").hide();
				$("#with_alert").show();
			}
		}

		complete_payments();
}

function autocomplete_product_field() {
	$('.autocomplete_field').on('railsAutocomplete.select', function(event, data) {
		$(this).closest("tr.fields").find("input.name").val(data.item.name);
		$(this).closest("tr.fields").find("input.price").val(data.item.price);
		$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	});
}

function complete_payments(){
	var suma = parseFloat(0);
	var payment_fields = parseFloat(0);
	$(".amount").filter(':visible').each(function(){  /// calculamos la suma total en sector pagos
		suma 						+= parseFloat($(this).val());
		payment_fields 	= payment_fields + 1;
	});
	if (payment_fields == 1) { /// si solo hay un tipo de pago, el monto es igual al total de la venta
		$("#payments").find(".amount").filter(':visible:last').val(total_venta);
	}	else { // en caso de haber más de un tipo de pago, la diferencia entre los pagos y el total de la venta se suma al último campo de pago
		var resto 	= parseFloat( total_venta - suma);
		last_amount = parseFloat($("#payments").find(".amount").filter(':visible:last').val());
		if (resto > 0) {
			$("#payments").find(".amount").filter(':visible:last').val(resto + last_amount);
		} else {
			if (resto < 0) { // en caso de que el total de venta haya disminuido, se actualizan los pagos
				payment_fields = 0;
				$(".amount").each(function(){
					payment_fields = payment_fields + 1;
					if (payment_fields == 1) {
						$(this).val(total_venta);
					}
					else {
						$(this).val(0);
					}
				});
			}
		}
	}
	check_payment_limit();
}

$(document).on('nested:fieldAdded:invoice_details', function(event){
  $('.datepicker').datepicker({
      language: "es",
      dateFormat: "dd/mm/yyyy",
      todayHighlight: true,
      autoClose: true,
      startView: 2
  });
	autocomplete_product_field();
	complete_payments();
	$(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');

	toogleConceptInTable();
	if_debit_note_selected();
});

$(document).on('nested:fieldAdded:tributes', function(event){
	$("input.price").trigger("change");
});

$(document).on('nested:fieldAdded:bonifications', function(event){
	var field 	= event.field;
	bonif_subtotal 	= field.find("input.bonif_subtotal");
	bonif_subtotal.val(calculateNetoConDescuentos().toFixed(2));
	if ($("#bonifications > tbody > tr:visible").length >= 2) {
		$("#bonifications_add_button").hide();
	}
});

$(document).on('change',".bonif_percentage",function(){
	bonif_subtotal = $(this).closest("tr.fields").find($("input.bonif_subtotal")).val();
	bonif_percentage = $(this).val();
	$(this).closest("tr.fields").find($("input.bonif_amount")).val((bonif_subtotal * (bonif_percentage / 100)).toFixed(2));
	calculateTotalOfInvoice();
});

$(document).on('nested:fieldRemoved:bonifications', function(event){
	calculateTotalOfInvoice();
	if ($("#bonifications > tbody > tr:visible").length < 2) {
		$("#bonifications_add_button").show();
	}
});

$(document).on('nested:fieldRemoved:invoice_details nested:fieldRemoved:tributes', function(event){
	var field 	= event.field;
	subtotal 	= field.find("input.subtotal");
	$(".remove-invoice-payment").attr("data-confirm", "¡Atención! Existen conceptos marcados para borrar pero los cambios no han sido guardados aún. ¿Desea continuar de todas formas?")
	calculateInvoiceDetailSubtotal(subtotal);
});

function if_debit_note_selected(){
	cbte_tipo = $("#invoice_cbte_tipo");
	if (COD_ND.indexOf(cbte_tipo.val()) != -1) {
	  concept_codes = $(".code");
	  concept_codes.each(function(){
	    if ($(this).val() == "") {
	      $(this).val("-");
	      $(this).attr("readonly",true);
	      $(this).closest("tr.fields").find(".tipo").val("Servicio");
				$(this).closest("tr.fields").find(".depot_id").attr("disabled", true);
	    }
	  })
	}
}

$(document).on("change", ".importe, #invoice_bonification", function(){
	calculateTotalOfInvoice();
});

$(document).on("change", ".amount", function(){
	check_payment_limit();
});

function check_payment_limit(){  //Funcion que indica si se superó el monto de factura al ingresar tipos de pagos
	var suma = parseFloat(0);
	$(".amount").each(function(){  /// calculamos la suma total en sector pagos
		suma = parseFloat(suma) + parseFloat($(this).val());
	});
	var popup = $("#myPopup");
	if (suma > total_venta) {
    popup.addClass("show");
	}
	else {
		popup.removeClass("show");
	}
}

$(document).on("change", "#invoice_cbte_tipo, #invoice_concepto", function(){
	if ($.inArray($(this).val(), ["03", "08", "13"]) > -1 ) {
		$("#payment_title").html("Devoluciones de dinero");
	}else{
		$("#payment_title").html("Pagos");
	}

	form = $(this).parents('form:first');
	cbte_tipo = $("#invoice_cbte_tipo");
	concepto = $("#invoice_concepto");
	$.get(form.attr("action")+'/change_attributes', {cbte_tipo: cbte_tipo.val(), concepto: concepto.val()}, null, "script");

});

$(document).on('railsAutocomplete.select', '.associated-invoice-autocomplete_field', function(event, data){
	if (COD_ND.indexOf($("#invoice_cbte_tipo").find('option:selected').val()) == -1) {
		form = $(this).parents('form:first');
		$.get(form.attr("action")+'/set_associated_invoice', {associated_invoice: $(this).val()}, null, "script");  // En el set_associated_invoice.js se cargan los detalles del associated invoice
	}
});

function changeView(tipo){
	$("#view").val(tipo).trigger("change");
};

$(document).on("click","#client_name", function(){
	$(this).val("");
});

function addRechargeToDetails(){
	var recharge = parseFloat($("#client_recharge").val() * -1);
	$("input.bonus_percentage").each(function() {
		$(this).val(recharge).trigger("change");
	})
}

$(document).on("change", ".type_of_payment", function(){
	if ($(this).val() == "1"){
		$(this).closest("tr.fields").find("select.credit_card").removeAttr("disabled");
	}else{
		$(this).closest("tr.fields").find("select.credit_card").attr("disabled", "disabled");
	}
})

$(document).on("change", "select.afip_id", function(){
	$(this).closest("tr.fields").find("input.desc").val($(this).find('option:selected').text());
})


$(document).on("change", "input.base_imp", function(){
	calculateTrib($(this));
})

$(document).on("change", "input.alic", function(){
	calculateTrib($(this));
})

function calculateTrib(e){
	base_imp = parseFloat(e.closest("tr.fields").find("input.base_imp").val());
	alic 	 = parseFloat(e.closest("tr.fields").find("input.alic").val());
	e.closest("tr.fields").find("input.importe").val((base_imp * ( alic/100)).toFixed(2)).trigger("change");
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

function toggleBonification(){
	var display = $(".bonifications").css('display');
	if (display == 'none'){
		$(".bonifications").show('fast');
		$([document.documentElement, document.body]).animate({
      	scrollTop: $("#div_ibonifications").offset().top - 100,
    	}, 500, function() {
    	$("#div_ibonifications").effect( "shake" );
    });
	}
}

function toggleTributes(){
	let display = $("#div_itributes").css('display');
	if (display == 'none') {
		$("#div_itributes").show('fast');
		$([document.documentElement, document.body]).animate({
      scrollTop: $("#div_itributes").offset().top - 100
    }, 500, function() {
    	$("#div_itributes").effect( "shake" );
    });
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
	}
}

function getPaymentRequest(url, data, action) {
  $.ajax({
    url: url,
    data: data ,
    contentType: "application/html",
    dataType: "html"
  }).done(function(response) {
    $("#" + action + "payment_detail").html(response)
		$('.datepicker').datepicker({
	      language: "es",
	      dateFormat: "dd/mm/yyyy",
	      todayHighlight: true,
	      autoclose: true,
	      startView: 2
	  });
  });
}

$(document).on("click", "#with_alert", function(){
	alert("No se pueden generar mas pagos ya que el monto faltante del comprobante es $ 0.00")
})

function hideConcept(text){
	var current_index = $('th:contains("'+ text +'")').index();
	if (index[current_index] == "hide"){
		index[current_index] = "show"
		$("table#details > thead > tr").find('th').eq(current_index).show()
	}else{
		index[current_index] = "hide"
		$("table#details > thead > tr").find('th').eq(current_index).hide()

	}
	toogleConceptInTable()
}

function toogleConceptInTable(){
	$.each(index, function(j, i){
		$("table#details > tbody > tr").each(function(){
			if(i == "hide"){
				$(this).find('td').eq(j).hide()
			}else{
				$(this).find('td').eq(j).show()
			}
		})
	})
}

$(document).on('nested:fieldRemoved', (event) => {
	$('[required]', event.field).removeAttr('required');
	$('[min]', event.field).removeAttr('min');
})
