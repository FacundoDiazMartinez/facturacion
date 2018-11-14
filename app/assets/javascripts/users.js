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
