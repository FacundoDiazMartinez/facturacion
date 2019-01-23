$(document).ready(() => {
  toggleForLcAlert();
})

$(document).load(() => {
  toggleForLcAlert();
})

function toggleForLcAlert() {
  	var alertElement = $('.alert-lc');
  	if(alertElement.text().length != 0){
	  	setTimeout( () => alertElement.slideDown(), 1000 );
	  	setTimeout( () => alertElement.slideUp( "slow", function() {
    		alertElement.html("");
  		}), 6000 );
	  	
	}
}

$(function() {
  $(document).on('pjax:complete', function(event, xhr, settings) {
    showFlashMessages(xhr);
  });
});

function showFlashMessages(jqXHR) {
  	if (!jqXHR || !jqXHR.getResponseHeader) return;
  	flashDiv = $(".alert-lc")
  	flash = jqXHR.getResponseHeader('X-Flash');
  	flash = JSON.parse(flash)
  	id = flash[2]
  	if (flash[0] == "alert") {
  		if (flashDiv.attr("id") != id){
  			$(".alert-lc-danger").html(flash[1])
  			flashDiv.attr("id", id);
  			toggleForLcAlert();
  		}
  	}else{
  		if (flashDiv.attr("id") != id){
    		$(".alert-lc-success").html(flash[1]);
    		flashDiv.attr("id", id);
    		toggleForLcAlert();
    	}
  	}
}