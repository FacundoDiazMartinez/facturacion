var totalTributos = 0

$(document).ready(runTaxes())

$(document).on("change", "select.afip_id", () => {
	$(this).closest("tr.fields").find("input.desc").val($(this).find('option:selected').text());
})

$(document).on("change", "input.alic", () => runTaxes())

$(document).on("nested:fieldAdded:tributes", () => runTaxes())

$(document).on("nested:fieldRemoved:tributes", () => runTaxes())

function runTaxes() {
  totalTributos  = 0
  baseImponible  = getOnlyDetails() - getTotalBonifications()

  $('#tributes > tbody > tr').each((index, currentField) => {
    setTaxesRowVars($(currentField))
    if (activo) {
      importe       = parseFloat((baseImponible * ( alicuotaTax.val() / 100 )).toFixed(2))
      totalTributos += parseFloat(importe)

      baseImpTax.val(baseImponible.toFixed(2))
      importeTax.val(importe.toFixed(2))
    }
  })
  $('.total_tributes').text(totalTributos.toFixed(2))
  runInvoice()
}

function getTotalTaxes() {
  return totalTributos
}

function setTaxesRowVars(currentField) {
  selectedTax   = currentField.find('select.afip_id').find('option:selected')
  baseImpTax    = currentField.find('input.base_imp')
  alicuotaTax   = currentField.find('input.alic')
  importeTax    = currentField.find('input.importe')
  activo        = (currentField.css('display') != "none") ? true : false
}
