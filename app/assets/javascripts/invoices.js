var total_venta = parseFloat(0);
var rest = parseFloat(0);
var index = {};

$( document ).ready(function() {
	autocomplete_field();
	if ($("#invoice_total").val() > 0) {
		total_venta = parseFloat($("#invoice_total").val());
	}

	if ($("#purchase_order_total").val() > 0) {
		total_venta = parseFloat($("#purchase_order_total").val());
	}

	showProductNamePopover ();
});

$(document).on('pjax:complete', function() {
	showProductNamePopover();
});

function showProductNamePopover () {
	$("#details tr.fields").each(function(){  // Mostrar popover del campo nombre con el nombre completo
		var name = $(this).find(".name");
		name.popover({
			title: name.val(),
			trigger: "hover"
		});

		var iva = $(this).find(".iva_aliquot");
		var iva_amount = $(this).find("input.iva_amount").val();
		iva.popover({
			title: "Monto I.V.A.: $ " + iva_amount,
			trigger: "hover"
		});

	});
}

function setConfirmParam() {
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
		title: "Monto I.V.A.: $" + iva_amount,
		trigger: "hover"
	});
}

$(document).on('keypress', function(e){
	if (e.keyCode == 13) {
    return false;
  }
})

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
	$(this).closest("tr.fields").find("select.iva_aliquot").val(data.item.iva_aliquot)
	$(this).closest("tr.fields").find("select.iva_aliquot").trigger("change")
	$(this).closest("tr.fields").find("input.bonus_percentage").val(recharge);
	calculateSubtotal($(this).closest("tr.fields").find("input.subtotal"));
});


$(document).on('railsAutocomplete.select', '.invoice-number-autocomplete_field', function(event, data){
	$(this).closest("div.form-group").find("input.invoice_id").val(data.item.id);
	$(this).closest("div.fields").find("div.info").html(
		"<p><strong>Total:</strong> $" + data.item.total + ". <strong>Monto faltante: </strong> $" + data.item.faltante + "</p>"
	);
	$(this).closest("div.fields").find("div.payments").show("fast")
})

function setVars(current_field){
	price				= current_field.closest("tr.fields").find("input.price");
	subtotal 			= current_field.closest("tr.fields").find("input.subtotal");
	quantity 			= current_field.closest("tr.fields").find("input.quantity");
	bonus_percentage 	= current_field.closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= current_field.closest("tr.fields").find("input.bonus_amount");
	iva_amount			= current_field.closest("tr.fields").find("input.iva_amount");
	iva_aliquot	 		= current_field.closest("tr.fields").find("select.iva_aliquot").find('option:selected');
}

$(document).on("change", ".price, .quantity, .bonus_percentage", function(){
	setVars($(this));

	total_neto 				= parseFloat(price.val()) * parseFloat(quantity.val());
	b_amount = (total_neto * (parseFloat(bonus_percentage.val()) / 100)).toFixed(2);
	bonus_amount.val(b_amount);

	calculateSubtotal(subtotal);
});

$(document).on("change", ".bonus_amount", function(){
	setVars($(this));

	total_neto 				= parseFloat(price.val()) * parseFloat(quantity.val());
	b_percentage 		= (parseFloat(bonus_amount.val()) * 100 / parseFloat(total_neto)).toFixed(2);
	bonus_percentage.val(b_percentage);

	calculateSubtotal(subtotal);
});

$(document).on("change", ".iva_aliquot", function(){
	setVars($(this));

	if (iva_aliquot.val() == "01" || iva_aliquot.val() == "02") {
		iva_am = 0.0
	}else{
		iva_am = ( price.val() * parseFloat( iva_aliquot.text() ) * quantity.val() ).toFixed(2);
	}
	iva_amount.val(iva_am);
	updateTooltip22($(this))
	calculateSubtotal(subtotal);
});

function calculateSubtotal(subtotal){
	setVars(subtotal);

	if (iva_aliquot.val() == "01" || iva_aliquot.val() == "02") {
		iva_am = 0.0
	}else{
		iva_am = ( price.val() * parseFloat(iva_aliquot.text()) * quantity.val() ).toFixed(2);
	}
	iva_amount.val(iva_am);
	Stotal = ((parseFloat(price.val())  * parseFloat(quantity.val()) ) + parseFloat(iva_amount.val()) - parseFloat(bonus_amount.val())).toFixed(2)
	subtotal.val(Stotal);

	var inv_total = parseFloat(0);
	$("tr.fields:visible > td > input.subtotal").each(function(){
	    inv_total = inv_total + parseFloat($(this).val());
	});
	$("tr.fields:visible > td > input.importe").each(function(){
	    inv_total = inv_total + parseFloat($(this).val());
	});
	$("#invoice_total").val(inv_total.toFixed(2));
	total_left = $("#invoice_total").val() - $("#invoice_total_pay").val();
	$("#total_left").val(total_left.toFixed(2));
	if ($("#invoice_cbte_tipo").length != 0) {
		var is_invoice = $.inArray($("#invoice_cbte_tipo").val(), ["01", "06", "11"] )
	}else{
		var is_invoice = false
	}
	if ($("#invoice_cbte_tipo").length != 0) {
		if (total_left > 0 || not(is_invoice)) {
			$("#normal").show();
			$("#with_alert").hide();
		}else{
			$("#normal").hide();
			$("#with_alert").show();
		}
	}

	$("span#total_left_venta").text("$" + total_left);

	subtotal.closest("td").find("strong").html("$" + subtotal.val())
	complete_payments();
}

function autocomplete_field() {
	$('.autocomplete_field').on('railsAutocomplete.select', function(event, data){
		$(this).closest("tr.fields").find("input.name").val(data.item.name);
		$(this).closest("tr.fields").find("input.price").val(data.item.price);
		$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	});
}

function complete_payments(){
	var suma = parseFloat(0);
	var payment_fields = parseFloat(0);
	$(".amount").each(function(){  /// calculamos la suma total en sector pagos
		suma = parseFloat(suma) + parseFloat($(this).val());
		payment_fields = payment_fields + 1;
	});
	if (payment_fields == 1) { /// si solo hay un tipo de pago, el monto es igual al total de la venta
		$("#payments").find(".amount").filter(':visible:last').val(total_venta);
	}
	else { // en caso de haber más de un tipo de pago, la diferencia entre los pagos y el total de la venta se suma al último campo de pago
		var resto = parseFloat( total_venta - suma);
		last_amount = parseFloat($("#payments").find(".amount").filter(':visible:last').val());
		if (resto > 0) {
			$("#payments").find(".amount").filter(':visible:last').val(resto + last_amount);
		}
		else {
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

$(document).on('nested:fieldAdded', function(event){

  $('.datepicker').datepicker({
      language: "es",
      dateFormat: "dd/mm/yyyy",
      todayHighlight: true,
      autoClose: true,
      startView: 2
  });

	custom_bonus = false; // Al empezar a trabajar con un nuevo producto, se resetea el custom_bonus (Definido al principio)
	autocomplete_field();
	complete_payments();
	$(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');

	toogleConceptInTable()
});

$(document).on('nested:fieldRemoved', function(event){
	 var field 	= event.field;
	 subtotal 	= field.find("input.subtotal")
	 calculateSubtotal(subtotal)
})


// $(document).on("change", ".subtotal", function(){
// 	var total = parseFloat(0);
// 	$(".subtotal").each(function(){
// 	    total = total + parseFloat($(this).val());
// 	});
// 	$(".importe").each(function(){
// 	    total = total + parseFloat($(this).val());
// 	});
// 	$("#invoice_total").val(total);

// 	total_left = $("#invoice_total").val() - $("#invoice_total_pay").val();
// 	$("#total_left").val(total_left);
// 	$("#total_left_venta").val(total_left);

// 	if (total_left > 0 ) {
// 		$("#normal").show();
// 		$("#with_alert").hide();
// 	}else{
// 		$("#normal").hide();
// 		$("#with_alert").show();
// 	}

// 	$("span#total_left_venta").text("$" + total);
// 	total_venta = total;

// 	$(this).closest("td").find("strong").html("$" + $(this).val())
// 	complete_payments();
// 	// iva_aliquot	 		= $(this).closest("tr.fields").find("select.iva_aliquot").trigger("change");
// });

$(document).on("change", ".importe", function(){
	var total = parseFloat(0);
	$("td:visible > .subtotal").each(function(){
	    total = total + parseFloat($(this).val());
	});
	$(".importe:visible").each(function(){
	    total = total + parseFloat($(this).val());
	});
	$("#invoice_total").val(total.toFixed(2));
	$("#total_left").val((parseFloat($("#invoice_total").val()) - parseFloat($("#invoice_total_pay").val())).toFixed(2));
	$("span#total_left_venta").text("$ " + $("#total_left").val());
	total_left = $("#total_left").val();
	if ($("#invoice_cbte_tipo").length != 0) {
		var is_invoice = $.inArray($("#invoice_cbte_tipo").val(), ["01", "06", "11"] )
	}else{
		var is_invoice = false
	}
	if ($("#invoice_cbte_tipo").length != 0) {
		if (total_left > 0 || !(is_invoice)) {
			$("#normal").show();
			$("#with_alert").hide();
		}else{
			$("#normal").hide();
			$("#with_alert").show();
		}
	}

	$(this).closest("td").find("strong").html("$" + $(this).val())
	complete_payments();
	iva_aliquot	 		= $(this).closest("tr.fields").find("select.iva_aliquot").trigger("change");
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
	if ($.inArray($(this).val(), ["03", "08", "13"])) {
		$("#payment_title").html("Devoluciones de dinero");
		//$("#total_left").val(0);
	}else{
		$("#payment_title").html("Pagos");
		//$("#total_left").val(( $("#invoice_total").val() -  $("#invoice_total_pay").val()).toFixed(2));
	}

	form = $(this).parents('form:first')
	cbte_tipo = $("#invoice_cbte_tipo")
	concepto = $("#invoice_concepto")
  	$.get(form.attr("action")+'/change_attributes', {cbte_tipo: cbte_tipo.val(), concepto: concepto.val()}, null, "script");
});


$(document).on('railsAutocomplete.select', '.associated-invoice-autocomplete_field', function(event, data){
	form = $(this).parents('form:first');
	$.get(form.attr("action")+'/set_associated_invoice', {associated_invoice: $(this).val()}, null, "script");
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
	e.closest("tr.fields").find("input.importe").val(base_imp * ( alic/100)).trigger("change");
}

function toggleHeader(){
	var display = $(".invoice-header").css('display');
	if (display == 'flex'){
		$(".invoice-header").hide('fast');
		$("#encabezado").html("").append($("<i class='fa fa-eye'></i>")).button();
		$("#encabezado").append(' Ver encabezado');
	}
	else{
		$(".invoice-header").show('fast');
		$("#encabezado").html("").append($("<i class='fa fa-eye-slash'></i>")).button();
		$("#encabezado").append(' Ocultar encabezado');
	}

}

function toggleTributes(){
	var display = $("#itributes").css('display');
	if (display == 'block'){
		$("#itributes").hide('fast');
		$("#tributos").html("").append($("<i class='fa fa-eye'></i>")).button();
		$("#tributos").append(' Ver tributos');
	}
	else{
		$("#itributes").show('fast');
		$("#tributos").html("").append($("<i class='fa fa-eye-slash'></i>")).button();
		$("#tributos").append(' Ocultar tributos');
		$([document.documentElement, document.body]).animate({
	        scrollTop: $("#itributes").offset().top
	    }, 500, function(){
	    	$("#itributes").effect( "shake" )
	    });

	}

}


function getPaymentRequest(url, data) {
  $.ajax({
    url: url,
    data: data ,
    contentType: "application/html",
    dataType: "html"
  }).done(function(response) {
    $("#payment_detail").html(response)
  });
}

$(document).on("click", "#with_alert", function(){
	alert("No se pueden generar mas pagos ya que el monto faltante del comprobante es $0.")
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
