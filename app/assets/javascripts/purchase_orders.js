$(document).on("change", '#purchase_order_shipping', function() {
		if ($(this).prop('checked')){
			$("#purchase_order_shipping_cost").show("");
			$("#purchase_order_shipping_cost").val("0.0");
		}else{
			$("#purchase_order_shipping_cost").hide();
			$("#purchase_order_shipping_cost").val("0.0");
		}
  });

$(document).on('railsAutocomplete.select', '.purchase_order-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.purchase_order-autocomplete_field").val(data.item.nomatch);
		}
	}
  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);
  	$(this).closest("tr.fields").find("input.prodPrice").val(data.item.price);
  	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
  	$(this).closest("tr.fields").find("input.supplier_code").val(data.item.supplier_code);
		$(this).closest("tr.fields").find("input.prodSubtotal").val(data.item.price);

		subtotal = $(this).closest("tr.fields").find("input.prodSubtotal");
		subtotal.trigger("change");
});

$(document).on("change", "#purchase_order_supplier_id", function(){
	$.get("/purchase_orders/set_supplier", {'supplier_id': $(this).val()}, null, "script");
});

$(document).on("change", ".prodPrice, .prodQuant", function(){

	price				= $(this).closest("tr.fields").find("input.prodPrice");
	subtotal 			= $(this).closest("tr.fields").find("input.prodSubtotal");
	quantity 			= $(this).closest("tr.fields").find("input.prodQuant");

	total = (parseFloat(price.val()) * parseFloat(quantity.val()));


	subtotal.val(total);
	subtotal.trigger("change");
});

$(document).on("change", '.prodSubtotal', function(){
	sumTotalPurchaseOrder()
});

$(document).on('nested:fieldRemoved', function(event){
	sumTotalPurchaseOrder()
})



function sumTotalPurchaseOrder(){
	sumaTotales = parseFloat(0);
	$(".prodSubtotal:visible").each(function(){
	  sumaTotales = parseFloat(sumaTotales) + parseFloat($(this).val());
	});
	sumaTotales = parseFloat(sumaTotales) +  parseFloat($("#purchase_order_shipping_cost").val())
	$('#purchase_order_total').val(sumaTotales);
	total_left == parseFloat(sumaTotales) - parseFloat($("#purchase_order_total_pay").val())
	if (total_left > 0) {
		$("#normal").show();
		$("#with_alert").hide();
	}else{
		$("#normal").hide();
		$("#with_alert").show();
	}
}

$(document).on("change", '#purchase_order_shipping_cost', function(){
	$(".prodSubtotal").trigger("change");
})

$(document).on("click", "#save_btn", function(){
	var suma = parseFloat(0);
	$(".purchase_order_payment_amount").each(function(){  /// calculamos la suma total en sector pagos
		suma = parseFloat(suma) + parseFloat($(this).val());
	});
	if (suma > parseFloat($("#faltante").text())) {
		return window.confirm("Los pagos superan el monto faltante. ¿Desea continuar de todas formas?");
	}
});

$(document).on('nested:fieldAdded', function(event){

  $('.datepicker').datepicker({
      language: "es",
      dateFormat: "dd/mm/yyyy",
      todayHighlight: true,
      autoClose: true,
      autoSize: true
  });

	$(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');
});


$(document).on('hidden.bs.modal', "#sendMailModal", function (e) {
	$("input#send_mail").val("false")
})

$(document).on('shown.bs.modal', "#sendMailModal", function (e) {
	$("input#send_mail").val("true")
})
