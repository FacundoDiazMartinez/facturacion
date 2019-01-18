$(document).on('railsAutocomplete.select', '.client-autocomplete_field', function(event, data){
	if (typeof data.item.nomatch !== 'undefined'){
		if (data.item.nomatch.length) {
			$('input[name^="client["]').each(function(){
			    $(this).val("");
			});
			$("input.client-autocomplete_field").val(data.item.nomatch);
		}
	}
	console.log(data)
	$.each( data.item, function( key, value ) {
	  $("#client_"+key).val(value);
	});
  	
});