
	$(document).on("change", "#service_cost_price", function(){
		setPrecioNetoForService();
	});

	$(document).on("change", "#service_gain_margin", function(){
		setPrecioNetoForService();
	});

	$(document).on("change", "#service_iva_aliquot", function(){
		setPrecioFinalForService();
	});

	$(document).on("change", "#service_net_price", function(){
		setPrecioFinalForService();
	});

	$(document).on("change", "#service_price", function(){
		setCostPriceForService();
	});

	$(document).on('change', '#service_product_category_id', function(){
		$.get('/products/product_category', {category_id: $(this).val()}, function(data){fillProductIvaForService(data)}, "script")
	})

function setPrecioNetoForService(){
	var costo 		= parseFloat($("#service_cost_price").val());
	var ganancia 	= parseFloat($("#service_gain_margin").val());
	var neto 		= $("#service_net_price");

	neto.val((costo * (1 + ganancia / 100)).toFixed(2));
	neto.trigger("change");
};

function setPrecioFinalForService(){
	var neto 		= parseFloat($("#service_net_price").val());
	if (($("#service_iva_aliquot :selected").text() == "Exento") || ($("#service_iva_aliquot :selected").text() == "No gravado") || ($("#service_iva_aliquot :selected").text() == "")) {
		var iva = 0
	}
	else {
		var iva 		= parseFloat($("#service_iva_aliquot :selected").text());
	}
	var final 		= $("#service_price");

	final.val((neto * (1 + iva)).toFixed(2));
};

function setCostPriceForService(){
	var neto 		= parseFloat($("#service_net_price").val());
	var costo 		= $("#service_cost_price").val();
	var ganancia 	= $("#service_gain_margin");
	var iva 		= parseFloat($("#service_iva_aliquot :selected").text());
	var final 		= $("#service_price").val();

	$("#service_net_price").val((final / (1 + iva)).toFixed(2));

	var neto 		= parseFloat($("#service_net_price").val());
	ganancia.val((neto / costo * 100 - 100).toFixed(2))
};

function fillProductIvaForService(data){
	var response = jQuery.parseJSON(data);
	$("#service_iva_aliquot").val(response[0].iva).trigger("change")
};
