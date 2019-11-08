$(document).on('click', '.toggle-card', (e) => {
  e.preventDefault()
  toggleCard($(e.target).data("target"))
  toggleLabel($(e.target).data("label-info"))
})

function toggleCard(cardSelector) {
  var card    = $(cardSelector);
  var display = card.css('display');
	if (display == 'none'){
		card.show('fast');
    shakeAnimationWithScroll(card)
	}	else {
		card.hide('fast');
	}
}

function toggleLabel(labelSelector) {
  var label    = $(labelSelector);
	(label.css('display') == 'none') ? label.show("fast") : label.hide("fast")
}


function shakeAnimationWithScroll(target) {
  $([document.documentElement, document.body]).animate({
      scrollTop: target.offset().top - 200,
    }, 300, function() {
    target.effect("shake");
  });
}
