$(document).on("keyup", ".subpayment_total", function(){
	total = parseFloat($(this).val());
	$("#receipt_total").val(total)
})

$(document).on("change", ".new_type_of_payment", function(){

	selected_payment 	= $(this).val();
	invoice_id 			= $("#invoice_id_for_payment").val();
	client_id 			= $("#client_id_for_payment").val();
	receipt_id 			= $("#receipt_id_for_payment").val();
	account_movement_id = $("#account_movement_id_for_payment").val();

	data = {invoice_id: invoice_id, client_id: client_id, receipt_id: receipt_id, account_movement_id: account_movement_id}

	switch (selected_payment) {
		case '0':
			getPaymentRequest("/payments/cash_payments/new", data);
			break;
		case '1':
			getPaymentRequest("/payments/card_payments/new", data);
			break;
		case '3':
			getPaymentRequest("/payments/bank_payments/new", data);
			break;
		case '4':
			getPaymentRequest("/payments/cheque_payments/new", data);
			break;
		case '5':
			getPaymentRequest("/payments/retention_payments/new", data);
			break;
		case '6':
			getPaymentRequest("/payments/account_payments/new", data);
			break;
		case '7':
			getPaymentRequest("/payments/debit_payments/new", data);
			break;
	}
})
