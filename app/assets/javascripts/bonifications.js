const MAX_BONIFICATIONS   = 2
var totalConceptos        = 0
var totalConceptosConIva  = 0
var totalDescontado       = 0
var totalDescuentos       = 0
var totalDescuentosIVA    = 0

$(document).on('change', '.bonif_percentage', function() {
  runBonifications()
})

$(document).on('nested:fieldAdded:bonifications', function(event){
  runBonifications()
  fillBonificationRow(event.field)
	toggleBonificationAddButton();
});

$(document).on('nested:fieldRemoved:bonifications', function(){
  runBonifications()
	toggleBonificationAddButton();
});

function runBonifications() {
  totalDescuentos       = 0
  totalDescuentosIVA    = 0
  totalConceptos        = getOnlyDetails()
  totalConceptosConIva  = getTotalDetails()
  discriminaIVA         = getTipoIVA()
  $("#bonifications > tbody > tr").each((index, element) => {
    setBonificationRowVars($(element))
    if (activo && alicuota.val() && totalConceptos) {
      descuento         = (alicuota.val() / parseFloat(100)) * totalConceptos
      descuentoIVA      = (alicuota.val() / parseFloat(100)) * totalConceptosConIva

      totalConceptos        -= descuento
      totalConceptosConIva  -= descuentoIVA
      totalDescuentos       += descuento
      totalDescuentosIVA    += descuentoIVA

      if (discriminaIVA) {
        monto.val(descuento.toFixed(2))
        subtotal.val(totalConceptos.toFixed(2))
      } else {
        monto.val(descuentoIVA.toFixed(2))
        subtotal.val(totalConceptosConIva.toFixed(2))
      }
    }
  })
  if (discriminaIVA) {
    $(".total_bonifications").text(totalDescuentos.toFixed(2))
  } else {
    $(".total_bonifications").text(totalDescuentosIVA.toFixed(2))
  }
  runTaxes()
}

function getTotalBonifications() {
  return totalDescuentos
}

function getTotalBonificationsIVA() {
  return totalDescuentosIVA
}

function toggleBonificationAddButton() {
  if ($("#bonifications > tbody > tr").filter(':visible').length < MAX_BONIFICATIONS) {
    $("#bonifications_add_button").show();
  } else {
    $("#bonifications_add_button").hide();
  }
}

function setBonificationRowVars(currentField) {
  alicuota		= currentField.find("input.bonif_percentage");
	monto 			= currentField.find("input.bonif_amount");
	subtotal 		= currentField.find("input.bonif_subtotal");
  activo      = (currentField.css('display') != "none") ? true : false
}

function fillBonificationRow(currentField) {
  $(currentField).closest("tr.fields").find("input.bonif_subtotal").val(totalDescontado.toFixed(2))
}
