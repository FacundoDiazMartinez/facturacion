$(document).on("keyup", ".subpayment_total", function(){
	total = parseFloat($(this).val());
	$("#receipt_total").val(total)
	
})