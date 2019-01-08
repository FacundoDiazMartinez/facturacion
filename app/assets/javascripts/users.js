function changeInformation(action){
    if (action == 'personal')
    {
      $("#basic_info").attr('style', 'display: block');
      $("#account").attr('style', 'display: none');
      //$("#personal_i").removeClass("active")
      $("#account_i").find('a').removeClass("active")
      $("#personal_i").find('a').addClass("active")
    }
    if (action == 'user')
    {
      $("#basic_info").attr('style', 'display: none');
      $("#account").attr('style', 'display: block');
      $("#personal_i").find('a').removeClass("active")
      //$("#account_i").removeClass("active")
      $("#account_i").find('a').addClass("active")
    }
  }

function displayForm(type){
  $(".card-options").hide();  
  $("#form").show("slow");
  if (type == "manager") {
    $("#company_code").hide();
    $("#code").removeAttr("required");

  }else{
     $("#company_code").show();
     $("#code").attr("required", "required");
  }
}

$(document).ready(function(){
  $("#company_code_popover").popover({
    content: "Para conseguir el código de la compañía debes solicitarselo al gerente de la misma. El lo puede encontrar los datos básicos de la compañía."
  });
});


$(document).on("click", ".activity-card", function(){
  url = $(this).data('link');
  $.get(url, {}, null, "script")
})