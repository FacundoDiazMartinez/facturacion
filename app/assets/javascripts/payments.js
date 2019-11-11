var totalPayments = 0

function runPayments() {
  totalPayments = 0
  $(".payment_amount").each((index, currentField) => {
    if ($(currentField).css('display') != 'none') {
      totalPayments += parseFloat($(currentField).text())
    }
  })
  $(".total_payments").text(totalPayments.toFixed(2))
  // runInvoice()
}

function getTotalPayments() {
  return totalPayments
}

function getPaymentRequest(url, data) {
  $.ajax({
    url: url,
    data: data ,
    contentType: "application/html",
    dataType: "html"
  }).done(function(response) {
    $(".payment_detail").html(response)
		initializeDatepicker()
  });
}

function initializePaymentsLimit() {
  $('.new_payment').on('click', (e) => {
    $('#details .depot_id').filter(':visible').each( (index, select) => {
      if ($(select).val() == "") {
        e.stopPropagation();
        alertify.alert("Depósitos de productos", "Selecciona el depósito del detalle antes de continuar.")
        $(select).focus()
        $([document.documentElement, document.body]).animate({
          scrollTop: $(select).offset().top - 600,
        }, 300 );
        return false
      }
    })
    if ($("#total_left").val() <= 0) {
      e.stopPropagation();
      alertify.alert("Monto faltante", "El monto faltante debe ser mayor a 0 para registrar pagos.")
    }
  });
}

$(document).on("change",".credit-card-select", function(){
  emptyCreditCard()
  fetch(`/receipts/get_cr_card_fees?id=${$(this).val()}`)
    .then((response) => response.json())
    .then((data) => {
      $(".credit-card-installments").empty().append($('<option>', {
        value: 0,
        text: 1
      }))
      data.map((item) => {
        $(".credit-card-installments").append($('<option>', {
          value: item['id'],
          text: item['cuotas']
        }))
      })
    })
})

$(document).on("change", ".credit-card-installments", function(){
  if ($(".credit-card-installments :selected").val() > 0) {
    fetch(`/receipts/get_fee_details?fee_id=${$(this).val()}&cr_card_id=${$(".credit-card-select").val()}`)
      .then((response) => response.json())
      .then((data) => {
        let fee = data.fee_data;
        let subtotal = parseFloat($(".credit-card-subtotal").val());
        let interes = 0

        if (data.fee_type == "Porcentaje") {
          $(".credit-card-interest-percentage").val(fee.percentage);
          if (subtotal > 0) { interes = parseFloat(fee.percentage) / 100 }
        } else {
          $(".credit-card-interest-percentage").val(((fee.coefficient - 1) * 100).toFixed(2));
          if (subtotal > 0) { interes = parseFloat(fee.coefficient) - 1 }
        }
        total = subtotal * (1 + interes);
        $(".credit-card-total").val(total.toFixed(2));
        $(".credit-card-interest-amount").val((subtotal * interes).toFixed(2));
        $(".fee-total").val((total / fee.quantity).toFixed(2));
      })
  } else { emptyCreditCard() }
})

$(document).on("change", ".credit-card-subtotal", function(){
  emptyCreditCard()
  $(".credit-card-installments").val(0);
})

function emptyCreditCard() {
  $(".credit-card-interest-percentage").val(0.00);
  $(".credit-card-total").val($(".credit-card-subtotal").val());
  $(".credit-card-interest-amount").val(0.00);
  $(".fee-total").val($(".credit-card-subtotal").val());
}
