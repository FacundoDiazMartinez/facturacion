$(document).on("click", "#notifications-link", function(event, data){
	container = $('#notification-container');
	$("#notifications").html("");

	if(container.is(":hidden")) {
	  	container.show("slow");
	}else{
	  	container.hide("slow");
	}
});


$(document).mouseup(function(e) 
{
    var container = $("#notification-container");

    if (!container.is(e.target) && container.has(e.target).length === 0) 
    {
        container.hide("slow");
        $("#notifications-preload").show();
    }
});