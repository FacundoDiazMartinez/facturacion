$(document).ready(function(){


 });

function reloadLocality(province, dropdown){
	$.ajax({
	    url: '/city/'+province+'/get_localities',
	    beforeSend: function() {
	       $("#"+dropdown).closest('.with-spinner').find('label').append(" <span class='fa fa-spinner fa-spin' id='spinner_icon' ></span>");
	    },
	    success:function(data) {
	      populateSelect(data, dropdown);
        $("#spinner_icon").remove();

	    },

	});
};

function populateSelect(data, dropdown){

	select = $("#"+dropdown)
  select.html("");
	$.each(data, function(id, d) {
    	select.append($("<option />").val(d[0]).text(d[1]));
	}

);

}
