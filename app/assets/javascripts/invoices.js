var total_venta = parseInt(0);
var rest = parseInt(0);

$( document ).ready(function() {
	autocomplete_field();
	if ($("#invoice_total").val() > 0) {
		total_venta = parseInt($("#invoice_total").val());
	}
});

function setConfirmParam() {
	$("#send_to_afip").prop('checked', true);
	$("#send_to_afip").closest('form').submit();
}

$(document).on('railsAutocomplete.select', '.invoice-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.autocomplete_field").val(data.item.nomatch);
		}
	}
	var recharge = parseFloat($("#client_recharge").val() * -1);

  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);
  	$(this).closest("tr.fields").find("input.tipo").val(data.item.tipo);
  	$(this).closest("tr.fields").find("input.price").val(data.item.price);
  	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	$(this).closest("tr.fields").find("input.subtotal").val(data.item.price);

	$(this).closest("tr.fields").find("input.name").tooltip({
		title: data.item.name,
		placement: "top"
	})

	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	$(this).closest("tr.fields").find("input.bonus_percentage").val(recharge).trigger("change");
});

$(document).on("change", ".price, .quantity", function(){
	price				= $(this).closest("tr.fields").find("input.price");
	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	iva_aliquot 		= $(this).closest("tr.fields").find("input.iva_aliquot");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");

	alert(bonus_amount.val())
	if (bonus_amount.val() != 0) {
		total = (parseFloat(price.val()) * parseFloat(quantity.val())) - parseFloat(bonus_amount.val());
	}else{
		total = (parseFloat(price.val()) * parseFloat(quantity.val()));
	}

	subtotal.val(total);
	subtotal.trigger("change");
});

$(document).on("change", ".bonus_percentage", function(){
	price				= $(this).closest("tr.fields").find("input.price");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");

	total 				= parseFloat(price.val()) * parseFloat(quantity.val());
	bonus_amount.val(total * (parseFloat(bonus_percentage.val()) / 100));
	price.trigger("change");
});

$(document).on("change", ".bonus_amount", function(){
	price				= $(this).closest("tr.fields").find("input.price");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");

	total 				= parseFloat(price.val()) * parseFloat(quantity.val());
	bonus_percentage.val(parseFloat(bonus_amount.val()) * 100 / parseFloat(total));
	price.trigger("change");
});

$(document).on("change", ".iva_aliquot", function(){
	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	iva_amount			= $(this).closest("tr.fields").find("input.iva_amount");
	iva_aliquot	 		= $(this).closest("tr.fields").find("select.iva_aliquot").find('option:selected');

	amount = parseFloat(subtotal.val()) / (1 + parseFloat(iva_aliquot.text())) * parseFloat(iva_aliquot.text());
	iva_amount.val(amount);
});

function autocomplete_field() {
	$('.autocomplete_field').on('railsAutocomplete.select', function(event, data){
			$(this).closest("tr.fields").find("input.name").val(data.item.name);
			$(this).closest("tr.fields").find("input.price").val(data.item.price);
			$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
	});
}

function complete_payments(){
	var suma = parseInt(0);
	var payment_fields = parseInt(0);
	$(".amount").each(function(){  /// calculamos la suma total en sector pagos
		suma = parseInt(suma) + parseInt($(this).val());
		payment_fields = payment_fields + 1;
	});
	if (payment_fields == 1) { /// si solo hay un tipo de pago, el monto es igual al total de la venta
		$("#payments").find(".amount").filter(':visible:last').val(total_venta);
	}
	else { // en caso de haber más de un tipo de pago, la diferencia entre los pagos y el total de la venta se suma al último campo de pago
		var resto = parseInt( total_venta - suma);
		last_amount = parseInt($("#payments").find(".amount").filter(':visible:last').val());
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
	autocomplete_field();
	complete_payments();
	$(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');
});

$(document).on('nested:fieldRemoved', function(event){
	 var field = event.field;
	 field.find("input.amount").val(0); //Ponemos en 0 el field que acabamos de eliminar (ya que no se elimina, se setea con display: none) para que funcione bien el complete_payments
})


$(document).on("change", ".subtotal", function(){
	var total = parseInt(0);
	$(".subtotal").each(function(){
	    total = total + parseInt($(this).val());
	});
	$("#invoice_total").val(total);
	total_venta = total;
	complete_payments();
	iva_aliquot	 		= $(this).closest("tr.fields").find("select.iva_aliquot").trigger("change");
});

$(document).on("change", ".amount", function(){
	check_payment_limit();
});

function check_payment_limit(){  //Funcion que indica si se superó el monto de factura al ingresar tipos de pagos
	var suma = parseInt(0);
	$(".amount").each(function(){  /// calculamos la suma total en sector pagos
		suma = parseInt(suma) + parseInt($(this).val());
	});
	var popup = $("#myPopup");
	if (suma > total_venta) {
    popup.addClass("show");
	}
	else {
		popup.removeClass("show");
	}
}

function setProduct(product, index){
	$("#"+index).find("input.product_id").val(product["id"]);
	$("#"+index).find("input.code").val(product["code"]);
  	$("#"+index).find("input.name").val(product["name"]);
	$("#"+index).find("input.name").prop('title', product["name"]);
  	$("#"+index).find("input.price").val(product["price"]);
  	$("#"+index).find("select.measurement_unit").val(product["measurement_unit"]);
	$("#"+index).find("input.subtotal").val(product["price"]);

	subtotal = $("#"+index).find("input.subtotal");
	$("#search_product_modal").modal('hide')
	subtotal.trigger("change");
};

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
}

$(document).on("click","#client_name", function(){
	$(this).val("");
})
