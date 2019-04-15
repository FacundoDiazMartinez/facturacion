$(document).on('ready',function(){
  calculateTotalLeft()
  if ($('#details > tbody > tr.fields').filter(":visible").length > 0) {
    $("#editReceiptClient").attr('data-toggle', 'tooltip');
    $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
    $("#editReceiptClient").tooltip();
  }
})

$(document).on('pjax:complete', function() { calculateTotalLeft() })

$(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', function(event, data){
  var band = false
  $(".invoice_comp_number").filter(':visible').each(function(){
    if ($(this).val() == data.item.comp_number){
      band = true
      alert("Este comprobante ya ha sido asignado.");
      $(".receipt_associated-invoice-autocomplete_field").val("");
      return false;
    }
  })
  if (band == false){
    $.get("/receipts/associate_invoice", {invoice_id: data.item.id}, "", "json")
      .done(function(details){
        $.each(details, function(i, detail){
          $(".add_nested_fields").click();
          tr = $("tr.fields").last();
          tr.find('input.tipo').val(detail.tipo);
          tr.find('input.invoice_comp_number').val(detail.label);
          tr.find('input.invoice_id').val(detail.id);
        	tr.find('input.invoice_total').val("$ " + detail.total.toFixed(2));
          tr.find('input.associated_invoices_total').val("$ " + detail.associated_invoices_total.toFixed(2));
          faltante = detail.total_left.toFixed(2) //- detail.associated_invoices_total.toFixed(2)
          tr.find('input.invoice_total_left').val("$ " + faltante);
          tr.find('input.invoice_total_pay').val("$ " + detail.total_pay.toFixed(2));
          tr.find('input.invoice_created_at').val(detail.created_at);
        })
        $("#editReceiptClient").attr('data-toggle', 'tooltip');
        $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
        $("#editReceiptClient").tooltip();

        calculateTotalLeft()
        $(".receipt_associated-invoice-autocomplete_field").val("")
      })
  }
});

$(document).on("change","#receipt_cbte_tipo",function(){
  if ($("#receipt_cbte_tipo option:selected").val() == "99") {
    $("#comp_number").attr("data-autocomplete","/receipts/autocomplete_credit_note");
  } else if ($("#receipt_cbte_tipo option:selected").val() == "00") {
    $("#comp_number").attr("data-autocomplete","/receipts/autocomplete_invoice");
  }
});

function calculateTotalLeft(){
  total = 0;
  $('.invoice_total_left:visible').each(function(){
    var res = $(this).val().replace("$ ", "");
    tipo = $(this).closest("tr.fields").find('input.tipo').val()
    if (tipo == "Nota de Crédito"){
      total -= parseFloat(res);
    }else{
      total += parseFloat(res);
    }
    $('#total_faltante').text('Total faltante: $ ' + total.toFixed(2));
  })
    return total;
}

$(document).ready(function(){
    calculateTotalPayed();
});

function calculateTotalPayed(){
  total_left = calculateTotalLeft();
  total_payed = 0;
  $('.pay').each(function(){
    var pag = $(this).text().replace("$ ", "");
      total_payed += parseFloat(pag);
    $('#total_pagado').text('Total pagado: $ ' + total_payed.toFixed(2));
    saldo = total_left - total_payed;
    $('#totales').text('Facturas $' + total_left + '   - Acumulado pagos: $' + total_payed.toFixed(2) + '   - A pagar: $' + (saldo).toFixed(2));
  })
}

$(document).on('nested:fieldRemoved', function(event){
  total = 0;
  $('.invoice_total_left').filter(':visible').each(function(){
    var res = $(this).val().replace("$ ", "");
    total= total + parseFloat(res);
  })

  $('#total_faltante').text('Total faltante: $ ' + total.toFixed(2));

  calculateTotalPayed();
});

$(document).on('nested:fieldAdded:account_movement', function(event){
  calculateTotalPayed();
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

$(document).on("change",".credit-card-select", function(){
  params = {
		id: $(this).val()
	}
  $(".credit-card-interest-percentage").val(0.00);
  $(".credit-card-total").val($(".credit-card-subtotal").val());
  $(".credit-card-interest-amount").val(0.00);
  $(".fee-total").val($(".credit-card-subtotal").val());
  $.get("/receipts/get_cr_card_fees",params,null,"script")
    .done(function(data){
      fees = jQuery.parseJSON(data);
        $(".credit-card-installments")
        .empty()
        .append($('<option>', {value: 0, text: 1}));
      $.each(fees, function(index, element){
        $(".credit-card-installments").append($('<option>', {
          value: element[1],
          text: element[0]
        }));
      });
    });
})

$(document).on("change", ".credit-card-installments", function(){
  if ($(".credit-card-installments :selected").text() > 0) {
    params = {
  		fee_id: $(this).val(),
      cr_card_id: $(".credit-card-select").val()
  	}
    $.get("/receipts/get_fee_details",params,null,"json").done(function(data){
      fee_type = data.fee_type;
      fee = data.fee_data;
      subtotal = parseFloat($(".credit-card-subtotal").val());

      if (fee_type == "Porcentaje") {
        $(".credit-card-interest-percentage").val(fee.percentage);
        if (subtotal > 0) {
          interes = parseFloat(fee.percentage) / 100;
        }
      } else {
        $(".credit-card-interest-percentage").val(((fee.coefficient - 1) * 100).toFixed(2));
        if (subtotal > 0) {
          interes = parseFloat(fee.coefficient) - 1;
        }
      }
      total = subtotal * (1 + interes);
      $(".credit-card-total").val(total.toFixed(2));
      $(".credit-card-interest-amount").val((subtotal * interes).toFixed(2));
      $(".fee-total").val((total / fee.quantity).toFixed(2));
    });
  }
})

$(document).on("change", ".credit-card-subtotal", function(){
  $(".credit-card-interest-percentage").val(0.00);
  $(".credit-card-total").val($(".credit-card-subtotal").val());
  $(".credit-card-interest-amount").val(0.00);
  $(".fee-total").val($(".credit-card-subtotal").val());
  $(".credit-card-installments").val(0);
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
