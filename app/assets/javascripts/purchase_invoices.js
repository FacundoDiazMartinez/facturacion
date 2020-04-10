$(document).on('railsAutocomplete.select', '.autocomplete-purchase-order-pi', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {	$(this).val(data.item.nomatch) }
	} else {
		$("#purchase_invoice_supplier_id").val(data.item.supplier_id).attr('readonly', true)
		$("#purchase_invoice_purchase_order_id").val(data.item.id)
		$("#purchase_invoice_net_amount").val(data.item.total)
		calculaTotalPI()
	}
})

$(document).on('focusin', '.autocomplete-purchase-order-pi', function() {
	$(this).data('value', $(this).val());
}).on('change', '.autocomplete-purchase-order-pi', function(){
	if ($(this).val() == "") {
		$("#purchase_invoice_purchase_order_id").val("")
		verificaOrdenDeCompra()
	} else {
		$("#purchase_invoice_purchase_order_id").val($(this).data('value'))
	}
})

$(document).on("change",".invoice_values", function(){
	aseguraValorNumerico(this)
	calculaTotalPI()
})

$(document).on('ready pjax:complete', function() {
	verificaOrdenDeCompra()
})

$(document).on("change", "#purchase_invoice_purchase_order_id", function() {
	verificaOrdenDeCompra()
})

function calculaTotalPI() {
	total = 0
	$(".invoice_values").each( function() { total += parseFloat($(this).val()) } )
	$("#purchase_invoice_total").val(total.toFixed(2))
}

function aseguraValorNumerico(element) {
	if (!$(element).val()) { $(element).val('0.0') }
}

function verificaOrdenDeCompra() {
	if ( $("#purchase_invoice_purchase_order_id").val() ) {
		$("#purchase_invoice_supplier_id").attr('readonly', true)
	} else {
		$("#purchase_invoice_supplier_id").removeAttr('readonly')
	}
}
