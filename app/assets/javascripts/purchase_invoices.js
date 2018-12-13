$(document).ready(function(){
invoice_amount = $("#purchase_invoice_total").val();
toggle_invoice_a_div();
})

function toggle_invoice_a_div(){
	if ($("#purchase_invoice_cbte_tipo").val() == 01) {
		$("#invoice_a_div").show();
		$("#purchase_invoice_total").attr("disabled","true");
		$( ".invoice_amount" ).trigger( "change" );
	}
	else {
		$("#invoice_a_div").hide();
		$("#purchase_invoice_total").removeAttr("disabled");
		$("#purchase_invoice_total").val(invoice_amount);
	}
}

$(document).on('railsAutocomplete.select', '.purchase-order-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).val(data.item.nomatch);
		}
	};
	$("#purchase_invoice_supplier_id").val(data.item.supplier_id);
	$("#purchase_invoice_total").val(data.item.total);
})

$(document).on("change", "#purchase_invoice_cbte_tipo", function(){
	toggle_invoice_a_div();
})

$(document).on("change","#purchase_invoice_net_amount", function(){ //Cuando cambia valor en MONTO NETO
	if ($("#purchase_invoice_iva_amount").val() != "") {
		$("#purchase_invoice_iva_amount").val(parseFloat($("#purchase_invoice_net_amount").val()) * parseFloat($("#purchase_invoice_iva_aliquot :selected").text()));
		$("#purchase_invoice_total").val(parseFloat($("#purchase_invoice_net_amount").val()) + parseFloat($("#purchase_invoice_iva_amount").val()));
	}
	else {
		$("#purchase_invoice_total").val($("#purchase_invoice_net_amount").val());
	}
})

$(document).on("change","#purchase_invoice_iva_amount", function(){ //Cuando cambia valor en IVA
	$("#purchase_invoice_total").val(parseFloat($("#purchase_invoice_net_amount").val()) + parseFloat($("#purchase_invoice_iva_amount").val()));
})

$(document).on("change","#purchase_invoice_iva_aliquot", function(){
	if ($("#purchase_invoice_iva_aliquot").val() != "") {
		$("#purchase_invoice_iva_amount").attr("disabled","true");
		$("#purchase_invoice_iva_amount").val(parseFloat($("#purchase_invoice_net_amount").val()) * parseFloat($("#purchase_invoice_iva_aliquot :selected").text()));
		$( ".invoice_amount" ).trigger( "change" );
	}
	else {
		$("#purchase_invoice_iva_amount").removeAttr("disabled");
	}
})
