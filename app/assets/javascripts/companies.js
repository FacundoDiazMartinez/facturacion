function setConfirmParam() {
	$("#send_to_afip").prop('checked', true);
	alert($("#send_to_afip").val());
	$("#send_to_afip").closest('form').submit();
}
