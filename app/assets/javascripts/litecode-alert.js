$(document).ready(() => {
  toggleForLcAlert();
})

$(document).load(() => {
  toggleForLcAlert();
})

function toggleForLcAlert() {
  var alertElement = $('.alert-lc');
  setTimeout( () => alertElement.slideDown(), 1000 );
  setTimeout( () => alertElement.slideUp(), 6000 );
}
