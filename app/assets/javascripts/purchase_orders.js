$(function() {
	$('#purchase_order_shipping').change(function() {
		if ($(this).prop('checked')){
			$("#purchase_order_shipping_cost").show("");
			$("#purchase_order_shipping_cost").val("0.0");
		}else{
			$("#purchase_order_shipping_cost").hide();
			$("#purchase_order_shipping_cost").val("");
		}
    });
});

$(document).on("change", "#purchase_order_supplier_id", function(){
	$.get("/purchase_orders/set_supplier", {'supplier_id': $(this).val()}, null, "script");
});