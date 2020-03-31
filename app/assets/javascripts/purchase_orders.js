$(document).on("change", '#purchase_order_shipping', function() {
	if ($(this).prop('checked')){
		$("#purchase_order_shipping_cost").show().val("0.00");
	} else {
		$("#purchase_order_shipping_cost").hide().val("0.00");
	}
});

$(document).on('railsAutocomplete.select', '.purchase_order-autocomplete_field', function(event, data) {
	if ((typeof data.item.nomatch !== 'undefined') && (data.item.nomatch.length)){
		$(this).closest(".fields").find("input.purchase_order-autocomplete_field").val(data.item.nomatch);
	}
	$(this).closest(".fields").find("input.product_id").val(data.item.id);
	$(this).closest(".fields").find("input.supplier_code").val(data.item.supplier_code);
	$(this).closest(".fields").find("input.name").val(data.item.name);
	$(this).closest(".fields").find("input.prodPrice").val(data.item.price);
	$(this).closest(".fields").find("input.prodSubtotal").val(data.item.price);

	sumTotalPurchaseOrder()
	disableSupplierSelect()
});

// $(document).on("change", "#purchase_order_supplier_id", () => {
// 	$.get("/purchase_orders/set_supplier", {'supplier_id': $(this).val()}, null, "script");
// });

$(document).on("change", ".prodPrice, .prodQuant", function() {
	calculateRows()
	sumTotalPurchaseOrder()
});

$(document).on('nested:fieldRemoved:purchase_order_details', function(event){
	sumTotalPurchaseOrder()
	disableSupplierSelect();
});

$(document).on("change", '.select-pu-supplier', function(){
	$(".pu-supplier-id").val($(".select-pu-supplier").val());
});

$(document).on('nested:fieldAdded:purchase_order_details', function(){
	disableSupplierSelect();
})

function disableSupplierSelect(){
	if ($("#purchase_order_supplier_id").val()) {
		if ($("#details > tbody > tr:visible").length > 0) {
			$("#purchase_order_supplier_id").attr("disabled", true);
		} else {
			$("#purchase_order_supplier_id").attr("disabled", false);
		}
	}
}

function calculateRows(){
	$(".fields:visible").each( function() {
		price		 = $(this).find("input.prodPrice");
		quantity = $(this).find("input.prodQuant");

		total = (parseFloat(price.val()) * parseFloat(quantity.val())).toFixed(2);
		$(this).find("input.prodSubtotal").val(total);
	})
}

function sumTotalPurchaseOrder(){
	sumaTotales = parseFloat(0);
	$(".prodSubtotal:visible").each( function() { sumaTotales = parseFloat(sumaTotales) + parseFloat($(this).val())	});
	sumaTotales += parseFloat($("#purchase_order_shipping_cost").val())
	$('#purchase_order_total').val( sumaTotales.toFixed(2) );
}

$(document).on("change", '#purchase_order_shipping_cost', function() { sumTotalPurchaseOrder() })

$(document).on('pjax:complete ready', () => {	disableSupplierSelect() })
