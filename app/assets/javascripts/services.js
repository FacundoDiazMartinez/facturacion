$(document).ready(function(){
	$("#service_cost_price").on("change", function(){
		setPrecioNetoForService();
	});

	$("#service_gain_margin").on("change", function(){
		setPrecioNetoForService();
	});

	$("#service_iva_aliquot").on("change", function(){
		setPrecioFinalForService();
	});

	$("#service_net_price").on("change", function(){
		setPrecioFinalForService();
	});

	$("#service_price").on("change", function(){
		setCostPriceForService();
	});

	$(document).on('change', '#service_product_category_id', function(){
		$.get('/products/product_category', {category_id: $(this).val()}, function(data){fillProductIvaForService(data)}, "script")
	})
});
	
function setPrecioNetoForService(){
	var costo 		= parseFloat($("#service_cost_price").val());
	var ganancia 	= parseFloat($("#service_gain_margin").val());
	var neto 		= $("#service_net_price");

	neto.val((costo * (1 + ganancia / 100)).toFixed(2));
	neto.trigger("change");
};

function setPrecioFinalForService(){
	var neto 		= parseFloat($("#service_net_price").val());
	var iva 		= parseFloat($("#service_iva_aliquot :selected").text());
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