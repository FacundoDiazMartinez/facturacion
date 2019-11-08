function remoteSubmit(form_id){
  form = $(form_id);
  $.get(form.attr("action"), form.serialize(), null , "script");
};

$(document).on('click',".clean-filter-button",function(e){
  let form = $(this).closest("form")
  form.find('select').val('');
  form.find('input').val('');
  remoteSubmit(form.attr('id'));
});
