var totalPayments = 0

function runPayments() {
  totalPayments = 0
  $(".payment_amount").each((index, currentField) => {
    if ($(currentField).css('display') != 'none') {
      totalPayments += parseFloat($(currentField).text())
    }
  })
  $(".total_payments").text(totalPayments.toFixed(2))
  runInvoice()
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
