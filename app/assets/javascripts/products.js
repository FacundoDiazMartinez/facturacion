$(document).ready(function(){
	$("#product_cost_price").on("change", function(){
		setPrecioNeto();
	});

	$("#product_gain_margin").on("change", function(){
		setPrecioNeto();
	});

	$("#product_iva_aliquot").on("change", function(){
		setPrecioFinal();
	});

	$("#product_net_price").on("change", function(){
		setPrecioFinal();
	});

	$("#product_price").on("change", function(){
		setCostPrice();
	});

	$(document).on('change', '#product_product_category_id', function(){
		$.get('/products/product_category', {category_id: $(this).val()}, function(data){fillProductIva(data)}, "script")
	})
});
	
function setPrecioNeto(){
	var costo 		= parseFloat($("#product_cost_price").val());
	var ganancia 	= parseFloat($("#product_gain_margin").val());
	var neto 		= $("#product_net_price");

	neto.val((costo * (1 + ganancia / 100)).toFixed(2));
	neto.trigger("change");
};

function setPrecioFinal(){
	var neto 		= parseFloat($("#product_net_price").val());
	var iva 		= parseFloat($("#product_iva_aliquot :selected").text());
	var final 		= $("#product_price");

	final.val((neto * (1 + iva)).toFixed(2));
};

function setCostPrice(){
	var neto 		= parseFloat($("#product_net_price").val());
	var costo 		= $("#product_cost_price").val();
	var ganancia 	= $("#product_gain_margin");
	var iva 		= parseFloat($("#product_iva_aliquot :selected").text());
	var final 		= $("#product_price").val();

	$("#product_net_price").val((final / (1 + iva)).toFixed(2));

	var neto 		= parseFloat($("#product_net_price").val());
	ganancia.val((neto / costo * 100 - 100).toFixed(2))
};

function fillProductIva(data){
	var response = jQuery.parseJSON(data);
	$("#product_iva_aliquot").val(response[0].iva).trigger("change")
};