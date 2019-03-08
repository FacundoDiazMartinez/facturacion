$(document).on('ready',function(){
  if ($('#details > tbody > tr.fields').filter(":visible").length > 0) {
    $("#editReceiptClient").attr('data-toggle', 'tooltip');
    $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
    $("#editReceiptClient").tooltip();
  }
})

$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
  $(this).closest('tr.fields').find('input.invoice_id').val(data.item.id);
	$(this).closest('tr.fields').find('input.invoice_total').val("$ " + data.item.total.toFixed(2));
  $(this).closest('tr.fields').find('input.invoice_total_left').val("$ " + data.item.total_left.toFixed(2));
  $(this).closest('tr.fields').find('input.invoice_total_pay').val("$ " + data.item.total_pay.toFixed(2));
  $(this).closest('tr.fields').find('input.invoice_created_at').val(data.item.created_at);


  $("#editReceiptClient").attr('data-toggle', 'tooltip');
  $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
  $("#editReceiptClient").tooltip();

	// var current_total = parseFloat($("#receipt_total").val())
	// $("#receipt_total").val(current_total + data.item.total)
  //
	// var no_invoices_associated = false
  //
	// $(".invoice_id").each(function(){
	// 	no_invoices_associated = $(this).val().length == 0
	// 	return no_invoices_associated
	// })
  //
	// if (!no_invoices_associated){
	// 	$('#editReceiptClient').attr("data-toggle", "");
	// 	$('#editReceiptClient').tooltip({title: "No es posible editar cliente mientras exista una factura vinculada."});
	// }

});

$(document).on('keyup','.receipt_associated-invoice-autocomplete_field', function(){
	if ($(this).val().length == 0) {
		$('#editReceiptClient').attr("data-toggle", "modal");
		$('#editReceiptClient').tooltip('dispose');
	}
})


$(document).on('click','#add_payment', function(){
  $("#total_left").empty();
  total_left = 0;
  $('#details > tbody > tr.fields').filter(":visible").each(function() {
    total_left = total_left + parseInt($(this).find('input.invoice_total_left').val());
  });

  if (total_left > 0) {
    $("#total_left").append("<p>Monto faltante a cubrir: $ " + total_left  + "</p>");
  }
})

// $(document).on('hidden.bs.modal','#clientModal', function (e) {
//   $("#receipt_client_id").trigger('change');
// })
//
// $(document).on('change','#receipt_client_id', function(){
//   $('#details > tbody > tr.fields').each(function() {
//     $(this).remove();
//   });
// })

$(document).on("change","#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_credit_card_id", function(){
  params = {
		id: $(this).val()
	}
  $.get("/receipts/get_cr_card_fees",params,null,"script")
    .done(function(data){
      fees = jQuery.parseJSON(data);
        $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_installments")
        .empty()
        .append($('<option>', {value: 0, text: 1}));
      $.each(fees, function(index, element){
        $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_installments").append($('<option>', {
          value: element[1],
          text: element[0]
        }));
      });
    });
})

$(document).on("change", "#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_installments", function(){
  if ($("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_installments :selected").text() > 0) {
    params = {
  		fee_id: $(this).val(),
      cr_card_id: $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_credit_card_id").val()
  	}
    $.get("/receipts/get_fee_details",params,null,"json").done(function(data){
      fee_type = data.fee_type;
      fee = data.fee_data;
      subtotal = parseFloat($("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_subtotal").val());

      if (fee_type == "Porcentaje") {
        $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_interest_rate_percentage").val(fee.percentage);
        if (subtotal > 0) {
          interes = parseFloat(fee.percentage) / 100;
          $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_total").val((subtotal * (1 + interes))toFixed(2));
        }
      } else {
        $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_interest_rate_percentage").val((1 - fee.percentage) * 100);
        if (subtotal > 0) {
          interes = parseFloat(fee.coefficient) - 1;
          $("#receipt_account_movement_attributes_account_movement_payments_attributes_0_card_payment_attributes_total").val((subtotal * (1 + interes))toFixed(2));
        }
      }

    });
  }
})

$(document).on('nested:fieldRemoved', function(event){
  var bandera = true;
  $('#details > tbody > tr.fields').filter(":visible").each(function() {
    if ($(this).find('input.invoice_id').val() != "") {
      bandera = false;
    }
  });
  if (bandera) {
    $("#editReceiptClient").attr('data-toggle', 'modal')
                           .tooltip('dispose');
  }
})
