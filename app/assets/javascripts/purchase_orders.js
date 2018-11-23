$(function() {
	$('#purchase_order_shipping').change(function() {
		if ($(this).prop('checked')){
			$("#purchase_order_shipping_cost").show("");
			$("#purchase_order_shipping_cost").val("0.0");
		}else{
			$("#purchase_order_shipping_cost").hide();
			$("#purchase_order_shipping_cost").val("0.0");
		}
    });
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
		$(this).closest("tr.fields").find("input.prodSubtotal").val(data.item.price);

		subtotal 			= $(this).closest("tr.fields").find("input.prodSubtotal");
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
	sumaTotales = parseFloat(0);
	$(".prodSubtotal").each(function(){
	  sumaTotales = parseFloat(sumaTotales) + parseFloat($(this).val());
	});
	$('#purchase_order_total').val(sumaTotales);
});
