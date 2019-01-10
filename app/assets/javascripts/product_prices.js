function clearPagination() {
  $('#page').val(1);
}

var checked_ids = [];

function manageArray(value) {
  console.log("Elemento seleccionado: " + value);
  var index = checked_ids.indexOf(value);
  if (index == -1) {
    checked_ids.push(value);
  } else {
    checked_ids.splice(index, 1);
  }
  console.log("Vector de productos: " + checked_ids);
}

function abrir(element_value) {
  manageArray(element_value);
  toggleBtnMenu();
}

function toggleBtnMenu() {
  var btn = $('#btnMenu');
  if (checked_ids.length > 0) {
    btn.removeAttr('disabled');
  } else {
    btn.attr('disabled', 'disabled');
  }
}

function setChecked() {
  $('input.checkbox-tag-multiple').each( (i, data) => {
    if (checked_ids.indexOf(data.value) != -1) {
      $(data).prop('checked', 'checked');
    }
  });
  toggleBtnMenu();
};

function getRequest() {
  $.ajax({
    url: '/products/edit_multiple',
    data: { product_ids: checked_ids } ,
    contentType: "application/html",
    dataType: "html",
    async: false
  }).done(function(response) {
    $("body").html(response)
  });
}
