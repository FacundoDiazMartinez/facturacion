const IVA_0 = ["01", "02"]
var totalDetalles    = 0
var totalDetallesIVA = 0

$(document).ready(() => autocompleteProductHandler())

$(document).on("change", ".price, .quantity, .bonus_percentage, .iva_aliquot", () => runDetails() )

$(document).on('nested:fieldAdded:invoice_details', (event) => {
	autocompleteProductHandler();
  runDetails();
});

$(document).on('nested:fieldRemoved:invoice_details', (event) => runDetails() )

$(document).on('railsAutocomplete.select', '.invoice-autocomplete_field', function(event, data){
  var recharge = parseFloat($("#client_recharge").val() * -1);

  if ((typeof data.item.nomatch !== 'undefined') && (data.item.nomatch.length)) {
		$(this).closest("tr.fields").find("input.autocomplete_field").val(data.item.nomatch);
	}

	fillInvoiceDetailInputs(data, this);

	$(this).closest("tr.fields").find("select.depot_id > option").each(function(index){
		if (index > 0) {
			name_to_clean = $(this).text();
			i = name_to_clean.indexOf(" [ Stock");
			if (i >= 0) {
				depot_name = jQuery.trim(name_to_clean).substring(0, i);
				$(this).text(depot_name);
			}
		}
	});

	data.item.depots_with_quantities.forEach(function(depot){
		$(this).closest("tr.fields").find("select.depot_id > option").each(function(i){
			if (i > 0) {
				option = $(this);
				if (depot.depot_id == option.val()) {
					depot_name = option.text();
					option.text(depot_name + " [ Stock: " + depot.quantity + " ]");
				}
			}
		});
	});

	if (data.item.tipo == "Servicio") {
		$(this).closest("tr.fields").find("select.depot_id").attr("disabled", true);
	} else {
		$(this).closest("tr.fields").find("select.depot_id > option").each(function(){
			if ($(this).val() == data.item.best_depot_id) {
				$(this).closest("tr.fields").find("select.depot_id").val(data.item.best_depot_id);
			}
		});
	}

  runDetails();
})

function runDetails() {
  totalDetalles = 0
  totalDetallesIVA = 0
  $("#details > tbody > tr.fields").each((index, currentField) => {
    setDetailRowVars($(currentField));
    if (activo) {
      detalle 	       = parseFloat(price.val() * quantity.val())
      bonificado       = detalle * (parseFloat(bonus_percentage.val()) / 100)
      subtotal_bruto   = detalle - bonificado
      monto_iva        = subtotal_bruto * getIvaAliquot(iva_aliquot)
      subtotal_neto    = subtotal_bruto + monto_iva

      totalDetalles    += subtotal_bruto
      totalDetallesIVA += subtotal_neto

      bonus_amount.val(bonificado.toFixed(2))
      iva_amount.val(monto_iva.toFixed(2))
      popoverIVA(iva_select, monto_iva.toFixed(2))
      subtotal.val(subtotal_neto.toFixed(2))
      subtotal.closest("td").find("strong").html("$ " + subtotal.val())
    }
  })
  $('.total_details').text(totalDetalles.toFixed(2))
  $('.detail_iva').text(totalDetallesIVA.toFixed(2))
  runBonifications()
}

function getOnlyDetails() {
  return totalDetalles
}

function getTotalDetails() {
  return totalDetallesIVA
}

function getIvaAliquot(iva_aliquot) {
  let porcentageIVA = 0;
  if ($.inArray(iva_aliquot.val(), IVA_0) == -1 ) {
    porcentageIVA =  parseFloat( iva_aliquot.text() )
  }
  return porcentageIVA
}

function setDetailRowVars(current_field) {
	code							= current_field.find("input.code");
	product_id				= current_field.find("input.product_id");
  product_name			= current_field.find("input.name");
	tipo					    = current_field.find("select.tipo");
	price							= current_field.find("input.price");
	subtotal 					= current_field.find("input.subtotal");
	quantity 					= current_field.find("input.quantity");
	depot_id 					= current_field.find("select.depot_id");
	bonus_percentage 	= current_field.find("input.bonus_percentage");
	bonus_amount			= current_field.find("input.bonus_amount");
	iva_amount				= current_field.find("input.iva_amount");
	iva_select				= current_field.find("select.iva_aliquot");
	iva_aliquot	 			= current_field.find("select.iva_aliquot").find('option:selected');
  activo            = (current_field.css('display') != "none") ? true : false
}

function autocompleteProductHandler() {
	$('.autocomplete_field').on('railsAutocomplete.select', function(event, data) {
    fillInvoiceDetailInputs(data, this);
	});
}

function fillInvoiceDetailInputs(data, currentRow) {
  $(currentRow).closest("tr.fields").find("input.product_id").val(data.item.id);
	$(currentRow).closest("tr.fields").find("input.name").val(data.item.name).attr('autocomplete', 'none');
	$(currentRow).closest("tr.fields").find("select.tipo").val(data.item.tipo);
	$(currentRow).closest("tr.fields").find("input.price").val(data.item.price.toFixed(2));
  $(currentRow).closest("tr.fields").find("input.quantity").val(1);
	$(currentRow).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
  $(currentRow).closest("tr.fields").find("select.iva_aliquot").val(data.item.iva_aliquot)

  $(currentRow).closest("tr.fields").find(".name").popover("dispose").popover({
    title: data.item.tipo,
    trigger: "hover",
    content: data.item.name,
  });
}

function popoverIVA(element, monto_iva) {
  element.popover('dispose').popover({
    title: "Monto I.V.A.",
    trigger: "hover",
    content: `$ ${monto_iva}`
  });
}

function blockDetailsForDebitNote() {
  $("#details > tbody > tr").each( (index, currentRow) => changeDebitNoteAttributes(currentRow) )
  runDetails()
}

function changeDebitNoteAttributes(currentField) {
  setDetailRowVars($(currentField))

  code.val("-").attr("readonly", true)
  tipo.val("Servicio")
  product_name.attr('autocomplete', 'none')
  depot_id.attr("readonly", true)
  price.removeAttr("readonly")
  iva_select.attr("readonly", true)
}
