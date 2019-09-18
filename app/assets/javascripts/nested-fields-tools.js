$(document).on('nested:fieldRemoved', (event) => {
	$('[required]', event.field).removeAttr('required')
	$('[min]', event.field).removeAttr('min')
})
