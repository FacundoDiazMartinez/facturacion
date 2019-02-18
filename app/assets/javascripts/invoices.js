var total_venta = parseFloat(0);
var rest = parseFloat(0);
var custom_bonus = false; // Variable para determinar si el usuario estableció un monto específico de monto bonificado
var index = {};

$( document ).ready(function() {
	autocomplete_field();
	if ($("#invoice_total").val() > 0) {
		total_venta = parseFloat($("#invoice_total").val());
	}

	if ($("#purchase_order_total").val() > 0) {
		total_venta = parseFloat($("#purchase_order_total").val());
	}
});

function setConfirmParam() {
	$("#send_to_afip").prop('checked', true);
	$("#send_to_afip").closest('form').submit();
}

function updateTooltip22(element) {
	var iva_amount = element.closest("td").find("input.iva_amount").val();
	$(element).tooltip('dispose');
	$(element).tooltip({
		title: "Monto I.V.A.: $" + iva_amount + ".",
		placement: "top"
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

	form = $(this).parents('form:first');
	alert(form.attr('id'));

	var recharge = parseFloat($("#client_recharge").val() * -1);

  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);
  	$(this).closest("tr.fields").find("select.tipo").val(data.item.tipo);
  	$(this).closest("tr.fields").find("input.price").val(data.item.price);
  	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	$(this).closest("tr.fields").find("input.subtotal").val(data.item.price);

	$(this).closest("tr.fields").find("input.name").tooltip({
		title: data.item.name,
		placement: "top"
	})

	//$(this).closest("tr.fields").find("input.price").tooltip({
	//	title: data.item.price * (parseFloat($(this).closest("tr.fields").find("select.iva_aliquot option:selected").html()) + 1),
	//	placement: "top"
	//})
	//console.log($(this).closest("tr.fields").find("select.iva_aliquot option:selected").html()),

	// subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	$(this).closest("tr.fields").find("select.iva_aliquot").trigger("change")
	$(this).closest("tr.fields").find("input.bonus_percentage").val(recharge).trigger("change");
});


$(document).on('railsAutocomplete.select', '.invoice-number-autocomplete_field', function(event, data){
	$(this).closest("div.form-group").find("input.invoice_id").val(data.item.id);
	$(this).closest("div.fields").find("div.info").html(
		"<p><strong>Total:</strong> $" + data.item.total + ". <strong>Monto faltante: </strong> $" + data.item.faltante + "</p>"
	);
	$(this).closest("div.fields").find("div.payments").show("fast")
})

$(document).on("change", ".price, .quantity", function(){

	price				= $(this).closest("tr.fields").find("input.price");
	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	iva_aliquot 		= $(this).closest("tr.fields").find("select.iva_aliquot");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");

	if (!custom_bonus) {
		b_amount = ((parseFloat(price.val()) * parseFloat(quantity.val())) * (parseFloat(bonus_percentage.val()) / 100)).toFixed(2)
		bonus_amount.val(b_amount);
	}

	// total = ((parseFloat(price.val()) * parseFloat(quantity.val())) - parseFloat(bonus_amount.val())).toFixed(2);

	// subtotal.val(total);
	// subtotal.trigger("change");
	iva_aliquot.trigger("change")
});

$(document).on("change", ".bonus_percentage", function(){
	price				= $(this).closest("tr.fields").find("input.price");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");

	total 				= parseFloat(price.val()) * parseFloat(quantity.val());
	b_amount = (total * (parseFloat(bonus_percentage.val()) / 100)).toFixed(2);
	bonus_amount.val(b_amount);
	price.trigger("change");
});

$(document).on("change", ".bonus_amount", function(){
	price				= $(this).closest("tr.fields").find("input.price");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");
	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");

	total 				= parseFloat(price.val()) * parseFloat(quantity.val());
	b_percentage 		= (parseFloat(bonus_amount.val()) * 100 / parseFloat(total)).toFixed(2);
	bonus_percentage.val(b_percentage);

	custom_bonus = true; //Aquí indicamos que el usuario está estableciendo un monto específico que debe respetarse siempre
	calculateSubtotal(subtotal);
});

$(document).on("change", ".iva_aliquot", function(){
	net_price 			= $(this).closest("tr.fields").find("input.price");
	iva_amount			= $(this).closest("tr.fields").find("input.iva_amount");
	iva_aliquot	 		= $(this).closest("tr.fields").find("select.iva_aliquot").find('option:selected');
	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	if (iva_aliquot.val() == "01" || iva_aliquot.val() == "02") {
		amount = 0.0
	}else{
		amount = ( net_price.val() * parseFloat( iva_aliquot.text() ) ).toFixed(2);
	}
	iva_amount.val(amount);
	updateTooltip22($(this))
	calculateSubtotal(subtotal);
});

function calculateSubtotal(subtotal){
	net_price 			= subtotal.closest("tr.fields").find("input.price");
	quantity 			= subtotal.closest("tr.fields").find("input.quantity");
	iva_amount			= subtotal.closest("tr.fields").find("input.iva_amount");
	bonus_amount		= subtotal.closest("tr.fields").find("input.bonus_amount");
	total = (( ( parseFloat( net_price.val() ) + parseFloat( iva_amount.val() ) ) * parseFloat( quantity.val() ) ) - parseFloat( bonus_amount.val() )).toFixed(2)
	subtotal.val(total);

	var inv_total = parseFloat(0);
	$("tr.fields:visible > td > input.subtotal").each(function(){
	    inv_total = inv_total + parseFloat($(this).val());
	});
	$("tr.fields:visible > td > input.importe").each(function(){
	    inv_total = inv_total + parseFloat($(this).val());
	});
	$("#invoice_total").val(inv_total);
	total_left = $("#invoice_total").val() - $("#invoice_total_pay").val();
	$("#total_left").val(total_left);

	if (total_left > 0 ) {
		$("#normal").show();
		$("#with_alert").hide();
	}else{
		$("#normal").hide();
		$("#with_alert").show();
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
	$('.datepicker').datepicker({
	      language: "es",
	      dateFormat: "dd/mm/yyyy",
	      todayHighlight: true,
	      autoclose: true,
	      startView: 2
	});
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
	$(".subtotal").each(function(){
	    total = total + parseFloat($(this).val());
	});
	$(".importe").each(function(){
	    total = total + parseFloat($(this).val());
	});
	$("#invoice_total").val(total);
	$("span#total_left_venta").val(total);
	total_venta = total;

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
