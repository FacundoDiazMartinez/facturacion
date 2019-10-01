
// debe evitar que se cambie el cliente cuando hayan facturas asociadas (o reiniciar el formulario?)

function initializeReceipt() {
  $(document).ready(() => { runReceipt() })

  $(document).on("pjax:complete", () => { runReceipt() })

  $(document).on("nested:fieldRemoved", () => {
    runReceipt()
    $("#save_btn_invoice").attr("class", "btn btn-danger")
  })

  $(document).on("change","#receipt_cbte_tipo",() => {
    if ($("#receipt_cbte_tipo option:selected").val() == "99") {
      $("#comp_number").attr("data-autocomplete","/receipts/autocomplete_credit_note");
    } else if ($("#receipt_cbte_tipo option:selected").val() == "00") {
      $("#comp_number").attr("data-autocomplete","/receipts/autocomplete_invoice_and_debit_note");
    }
  })

  $(document).on('railsAutocomplete.select', '.receipt_associated-invoice-autocomplete_field', (event, data) => {
    $(".receipt_associated-invoice-autocomplete_field").val("")
    if (unrepeatedInvoices(data.item.comp_number)) {
      fetch(`/receipts/associate_invoice?invoice_id=${data.item.id}`)
        .then((response) => response.json())
        .then((details) => {
          fillDetails(details)
          runReceipt()
        })
        .catch((error) => {
          console.log(error)
          runReceipt()
        })
    }
  })

  $(document).on("change", "select", function () {
    $("#save_btn_receipt").attr("class", "btn btn-danger");
  });

  $(document).on("keyup", "input:visible", function () {
    $("#save_btn_receipt").attr("class", "btn btn-danger");
  });
}

function runReceipt(){
  let total_payed = totalReceiptPayments()
  let saldo       = total_payed * (-1)

  if (receiptConfirmed()) {
    saldo += totalInvoicesPayed()
    setSaldoLabels(saldo)
  } else {
    var invoices_array = []
    $('#details > tbody > tr.fields').filter(":visible")
      .each((index, current_field) => invoices_array.push($(current_field).find('.invoice_id').val()) )

    if (invoices_array.length > 0) {
      $.get(`/invoices/get_total_payed_and_left`, { invoices_ids: invoices_array },null,"json")
      .done((data) => {
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
            $(current_field).find(".invoice_total_pay").val("$ " + current_invoice_total_payed.toFixed(2));
            $(current_field).find(".invoice_total_left").val("$ " + current_invoice_total_left.toFixed(2));
          }
        })
        setSaldoLabels(saldo)
      })
    }
  }
}

function unrepeatedInvoices(comp_number) {
  unrepeated = true
  $("#details > tbody > tr.fields .invoice_comp_number").filter(':visible').each((index, currentElement) => {
    if ($(currentElement).val() == comp_number) {
      alertify.alert("Comprobante asociado", "El comprobante seleccionado ya ha sido asignado a los detalles de este recibo.")
      unrepeated = false
    }
  })
  return unrepeated
}

function fillDetails(data){
  data.map((item) => {
    $(".add_nested_fields").click();
    tr = $("tr.fields").last();
    tr.find('input.tipo').val(item.tipo);
    tr.find('input.invoice_comp_number').val(item.label);
    tr.find('input.invoice_id').val(item.id);
    tr.find('input.invoice_total').val("$ " + item.total.toFixed(2));
    tr.find('input.associated_invoices_total').val("$ " + item.associated_invoices_total.toFixed(2));
    tr.find('input.invoice_total_left').val("$ " + item.total_left.toFixed(2));
    tr.find('input.invoice_total_pay').val("$ " + item.total_pay.toFixed(2));
    tr.find('input.invoice_created_at').val(item.created_at);
  })
}

function receiptConfirmed(){ return $('#receipt_state').val() == "Finalizado" }

function totalReceiptPayments() {
  let monto = 0
  $('.pay').each((index, currentField) => {
    let montoPagado = $(currentField).text().replace("$ ", "")
    if (montoPagado) {
      monto += parseFloat(montoPagado)
    }
  });
  $('.final_total').text(monto.toFixed(2))
  $('#receipt_total').val(monto.toFixed(2))
  return monto
}

function totalInvoicesPayed() {
  let pagosEnFactura = 0
  $('.total_payed_invoice').each(function(){
    let montoPagado = $(this).val();
    if (montoPagado) { pagosEnFactura += parseFloat(montoPagado) }
  })
  console.log(pagosEnFactura)
  return pagosEnFactura
}

function setSaldoLabels(saldo) {
  if (saldo > 0) {
    $('.saldo_label').text("Monto faltante")
    $('.total_payments_left').text(saldo.toFixed(2))
  } else {
    $('.saldo_label').text("Saldo a favor futuras compras")
    $('.total_payments_left').text((saldo * (-1)).toFixed(2))
  }
}
