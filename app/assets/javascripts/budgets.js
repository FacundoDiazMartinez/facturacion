$(document).on('railsAutocomplete.select', '.budget_detail-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$(this).closest("tr.fields").find("input.autocomplete_field").val(data.item.nomatch);
		}
	}
		var recharge = parseFloat($("#client_recharge").val() * -1);
		bonus = recharge
  	$(this).closest("tr.fields").find("input.product_id").val(data.item.id);
  	$(this).closest("tr.fields").find("input.name").val(data.item.name);
  	$(this).closest("tr.fields").find("input.price").val(data.item.price);
		$(this).closest("tr.fields").find("input.bonus_percentage").val(bonus);
		$(this).closest("tr.fields").find("input.bonus_amount").val((data.item.price * ( bonus / 100)).toFixed(2));
  	$(this).closest("tr.fields").find("select.measurement_unit").val(data.item.measurement_unit);
		$(this).closest("tr.fields").find("input.subtotal_budget").val((data.item.price * (1 - bonus / 100)).toFixed(2)).trigger("change");
		$(this).closest("tr.fields").find("select.depot_id option")[1].selected = true;
		//$(this).closest("tr.fields").find("input.bonus_percentage").trigger("change");
	$(this).closest("tr.fields").find("input.name").tooltip({
		title: data.item.name,
		placement: "top"
	})
});

$(document).on("change", ".subtotal_budget", function(){
	calculateBudgetSubtotal($(this));
});

$(document).on('nested:fieldRemoved', function(event){
	 var field 	= event.field;
	 subtotal 	= field.find("input.subtotal_budget");
	 calculateBudgetSubtotal(subtotal);
})

function calculateBudgetSubtotal(subtotal){
	var total = parseFloat(0);
	$(".subtotal_budget:visible").each(function(){
	    total = total + parseFloat($(this).val());
	});

	$("#budget_total").val(total);
	total_venta = total;
	complete_payments();
	//iva_aliquot	 		= subtotal.closest("tr.fields").find("select.iva_aliquot").trigger("change");
}

$(document).on("change", ".price, .quantity, .bonus_amount, .bonus_percentage", function(){
	price				= $(this).closest("tr.fields").find("input.price");
	// subtotal 			= $(this).closest("tr.fields").find("input.subtotal_budget");
	quantity 			= $(this).closest("tr.fields").find("input.quantity");
	bonus_percentage 	= $(this).closest("tr.fields").find("input.bonus_percentage");
	bonus_amount		= $(this).closest("tr.fields").find("input.bonus_amount");


	b_amount = ((parseFloat(price.val()) * parseFloat(quantity.val())) * (parseFloat(bonus_percentage.val()) / 100)).toFixed(2);
	bonus_amount.val(b_amount);
	subtotal = ((parseFloat(price.val()) * parseFloat(quantity.val())) - b_amount).toFixed(2);
	$(this).closest("tr.fields").find("input.subtotal_budget").val(subtotal);
	console.log(subtotal);
	$(this).closest("tr.fields").find("input.subtotal_budget").trigger("change");
});
