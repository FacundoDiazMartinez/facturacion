
$( document ).ready(function() {
    var total_venta = parseInt(0);
		var rest = parseInt(0);
		autocomplete_field();
});

$(document).on('railsAutocomplete.select', '.autocomplete_field', function(event, data){
	console.log(data.item)
	if (data.intem == NaN){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.autocomplete_field").val(data.item.nomatch);
		}
	}
  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);
  	$(this).closest("tr.fields").find("input.price").val(data.item.price);
  	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
});

$(document).on("change", ".price, .quantity", function(){

	price				= $(this).closest("tr.fields").find("input.price");
	subtotal 			= $(this).closest("tr.fields").find("input.subtotal");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");

	if (bonus_amount.length) {
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
	iva_amount.val(parseFloat(subtotal.val()) * parseFloat(iva_aliquot.text()))
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
	$(".amount").each(function(){
		suma = parseInt(suma) + parseInt($(this).val());
	});

	var resto = parseInt( total_venta - suma);
	if (resto > 0) {
		$("#payments").find(".amount").filter(':visible:last').val(resto);
	}
}

$(document).on('nested:fieldAdded', function(event){
	autocomplete_field();
	complete_payments();
	$(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');
});


$(document).on("change", ".subtotal", function(){
	var total = parseInt(0);
	$(".subtotal").each(function(){
	    total = total + parseInt($(this).val());
	});
	$("#payments").find(".amount").filter(':visible:first').val(total);
	total_venta = total;
	// subtotal 	= $(this).closest("tr.fields").find("input.subtotal");
});
