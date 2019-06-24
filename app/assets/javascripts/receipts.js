$(document).on('ready',function(){
  if ($('#details > tbody > tr.fields').filter(":visible").length > 0) {
    $("#editReceiptClient").attr('data-toggle', 'tooltip');
    $("#editReceiptClient").attr('title', 'No es posible editar el cliente si existen facturas asociadas.');
    $("#editReceiptClient").tooltip();
  }
  calculatePagadoAndFaltantePerInvoice();
})

$(document).on('pjax:complete', function() {
  calculatePagadoAndFaltantePerInvoice();
})

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
          console.log(data.item);
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
        $(".receipt_associated-invoice-autocomplete_field").val("");
        calculatePagadoAndFaltantePerInvoice();
      });

  }
});

$(document).on("change","#receipt_cbte_tipo",function(){
  if ($("#receipt_cbte_tipo option:selected").val() == "99") {
    $("#comp_number").attr("data-autocomplete","/receipts/autocomplete_credit_note");
  } else if ($("#receipt_cbte_tipo option:selected").val() == "00") {
    $("#comp_number").attr("data-autocomplete","/receipts//receipts/autocomplete_invoice_and_debit_note");
  }
});

function calculatePagadoAndFaltantePerInvoice(){
  var total_payed = 0 // TOTAL PAGADO
  var saldo = 0
  $('.pay').each(function(){
    // suma los montos de todos los pagos
    var monto_pagado = $(this).text().replace("$ ", "");
    if (monto_pagado) {
      // entra si es un número
      total_payed += parseFloat(monto_pagado);
    }
  });
  $('#total_pagado').text(`Total pagado: $ ${total_payed.toFixed(2)}`);
  $('#receipt_total').val(total_payed.toFixed(2))
  saldo += total_payed * (-1)
  if ($('#receipt_state').val() == "Finalizado" ) {
    pagos_en_factura = 0;
    $('.total_payed_invoice').each(function(){
      // suma los montos de todos los pagos
      var monto_pagado = $(this).val();
      if (monto_pagado) {
        // entra si es un número
        pagos_en_factura += parseFloat(monto_pagado);
      }
    });
    saldo += pagos_en_factura
    if (saldo > 0) {
      $('#total_faltante').text('Total faltante: $ ' + saldo.toFixed(2));
    } else {
      $('#total_faltante').text('Saldo a favor futuras compras: $ ' + (saldo * (-1)).toFixed(2));
    }
  } else {
    var invoices_array = []
    //junta los id de las facturas en un array
    $('#details > tbody > tr.fields').filter(":visible").each(function(index, current_field){
      invoices_array.push($(current_field).find('.invoice_id').val())
    });
    if (invoices_array.length > 0) {
      $.get(`/invoices/get_total_payed_and_left`, { invoices_ids: invoices_array },null,"json")
      .done(function(data){
        console.table(data)
        $('#details > tbody > tr.fields').filter(":visible").each(function(index, current_field){
          // asigna los valores reales de la factura a las variables
          var current_invoice_total_payed = parseFloat(data[index]['total_payed']);
          var current_invoice_real_total_left = parseFloat(data[index]['real_total_left']);
          saldo += current_invoice_real_total_left;
          var current_invoice_total_left = parseFloat(data[index]['total_left']);
          var current_invoice_real_total = parseFloat(data[index]['real_total']);
          //
          if (current_invoice_real_total_left > 0) {
            if (total_payed <= current_invoice_real_total_left) {
              // si la suma de los pagos es menor o igual al faltante de la factura actual
              // suma el monto pagado y resta el monto faltante
              current_invoice_total_payed += total_payed;
              current_invoice_total_left -= total_payed;
              total_payed = 0;
            } else {
              // si la suma de los pagos es mayor al monto real faltante de la factura actual
              current_invoice_total = parseFloat($(current_field).find(".invoice_total").val().replace("$", "")); // cambié el valor de text() por val()
              current_invoice_total_payed = current_invoice_real_total;
              current_invoice_total_left = current_invoice_total - current_invoice_total_payed;
              total_payed -= current_invoice_real_total_left;
            }
            console.log(`SALDO ${saldo} ${index}`)
            $(current_field).find(".invoice_total_pay").val("$ " + current_invoice_total_payed.toFixed(2));
            $(current_field).find(".invoice_total_left").val("$ " + current_invoice_total_left.toFixed(2));
          }
        });
        console.log(`SALDO ${saldo}`)
        if (saldo > 0) {
          $('#total_faltante').text('Total faltante: $ ' + saldo.toFixed(2));
        } else {
          $('#total_faltante').text('Saldo a favor futuras compras: $ ' + (saldo * (-1)).toFixed(2));
        }
      });
    }
  }
}

$(document).on('nested:fieldRemoved:receipt_details', function(event){
  calculatePagadoAndFaltantePerInvoice();
});

$(document).on('nested:fieldRemoved', function(event){
  calculatePagadoAndFaltantePerInvoice();
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
    total_left += parseInt($(this).find('input.invoice_total_left').val());
  });

  if (total_left > 0) {
    $("#total_left").append("<p>Monto faltante a cubrir: $ " + total_left  + "</p>");
  }
})

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
