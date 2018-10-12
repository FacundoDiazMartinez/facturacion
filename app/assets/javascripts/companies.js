$(document).ready(function(){
	$('.datepicker').datepicker({
	    language: 'es'
	});
});

function reloadLocality(){
	code = $("#company_city").val();
	$.ajax({
	    type: "GET",
	    url: "/city/"+code+"/get_localities",
	    dataType: "json",
	    success: function(data){
	        var $select = $("#company_location");
	        $select.html("")
			$.each(data, function(i, d) {
		        $('<option>').val(d[0]).text(d[1]).appendTo($select);     
		    });
	    }        
	});
}
