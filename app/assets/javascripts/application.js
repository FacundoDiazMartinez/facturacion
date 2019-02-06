// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.validate
//= require jquery.pjax
//= require jquery.validate.localization/messages_es
//= require main-mockup
//= require private_pub
//= require froala_editor.min.js
//= require jquery_nested_form
//= require invoices
//= require users
//= require litecode-alert
//= require popper
//= require bootstrap
//= require bootstrap-toggle
//= require z.jquery.fileupload
//= require activestorage
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.es.js
//= require_tree .
//= require autocomplete-rails
//= require languages/es.js


// -----------------------------------------PLUGINS ADICIONALES WYSIWYG:
//= require plugins/align.min.js
//= require plugins/char_counter.min.js
//= require plugins/code_beautifier.min.js
//= require plugins/code_view.min.js
//= require plugins/colors.min.js
//= require plugins/entities.min.js
//= require plugins/font_family.min.js
//= require plugins/font_size.min.js
//= require plugins/fullscreen.min.js
//= require plugins/help.min.js
//= require plugins/inline_class.min.js
//= require plugins/inline_style.min.js
//= require plugins/line_breaker.min.js
//= require plugins/line_height.min.js
//= require plugins/link.min.js
//= require plugins/lists.min.js
//= require plugins/paragraph_format.min.js
//= require plugins/paragraph_style.min.js
//= require plugins/quick_insert.min.js
//= require plugins/quote.min.js
//= require plugins/table.min.js
//= require plugins/special_characters.min.js
//= require plugins/url.min.js

//= require third_party/image_aviary.min.js
//= require third_party/image_tui.min.js
// -----------------------------------------FIN PLUGINS ADICIONALES WYSIWYG

$(document).ready(function() {

  $(document).pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '[data-pjax-container]');

  $('btn').on('click', function() {
    var $this = $(this);
    var loadingText = " Espere...";
    if ($(this).html() !== loadingText) {
      $this.data('original-text', $(this).html());
      $this.html(loadingText);
    }
    setTimeout(function() {
      $this.html($this.data('original-text'));
    }, 2000);
  });

  $(document).on("click","#image", function(){
    $('#file_input').click();
  })

  $(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');


  $('.toogle').bootstrapToggle();

  $('.datepicker').datepicker({
      language: "es",
      dateFormat: "dd/mm/yyyy",
      todayHighlight: true,
      autoclose: true,
      startView: 2
  });
});


$(document).on("keyup", "input.ui-autocomplete-input", function(e){
  target = $($(this).data("id-element"))
  if (target.length != 0){
    target.val("")
  }
});

$(document).on('pjax:complete', function() {
  $(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');

  $('.toggle').bootstrapToggle();

  $('.datepicker').datepicker({
      language: "es",
      dateFormat: "dd/mm/yyyy",
      todayHighlight: true,
      autoclose: true,
      startView: 2
  });
})

function remoteSubmit(form_id){
  form = $(form_id);
  $.get(form.attr("action"), form.serialize(), null , "script");
};

function reloadLocality(province, dropdown){
  $.ajax({
      url: '/city/'+province+'/get_localities',
      beforeSend: function() {
         $("#"+dropdown).closest('.with-spinner').find('label').append(" <span class='fa fa-spinner fa-spin' id='spinner_icon' ></span>");
      },
      success:function(data) {
        populateSelect(data, dropdown);
        $("#spinner_icon").remove();
      },
  });
};

$(document).on('pjax:complete', function() {
  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput    = $(elem);
    var form         = $(fileInput.parents('form:first'));
    var submitButton = form.find('input[type="submit"]');
    fileInput.fileupload({
      fileInput:       fileInput,
      url:             form.data('url'),
      type:            'POST',
      autoUpload:       true,
      formData:         form.data('form-data'),
      paramName:        'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
      replaceFileInput: true,
      start: function (e) {
        submitButton.prop('disabled', true);
        $('.caption').slideDown(250); //.fadeIn(250)
      },
      done: function(e, data) {
        submitButton.prop('disabled', false);
        // extract key and generate URL from response
        var key   = $(data.jqXHR.responseXML).find("Key").text();
        var url   = 'https://' + form.data('host') + '/litecode.facturacion/' + key;

        // create hidden field
        if (!$('#hidden_photo').length){
          var input = $("<input />", { type:'hidden', name: fileInput.attr('name'), value: url, id: 'hidden_photo' })
        }else {
          $("#hidden_photo").val(url);
        }
        form.append(input);
        $("#image").attr("src", url);
        $('.caption').slideUp(250); //.fadeIn(250)
      },
      fail: function(e, data) {
        submitButton.prop('disabled', false);
      }
    });
  });
});

$(document).on("ready", function(){
  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput    = $(elem);
    var form         = $(fileInput.parents('form:first'));
    var submitButton = form.find('input[type="submit"]');
    fileInput.fileupload({
      fileInput:       fileInput,
      url:             form.data('url'),
      type:            'POST',
      autoUpload:       true,
      formData:         form.data('form-data'),
      paramName:        'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
      replaceFileInput: true,
      start: function (e) {
        submitButton.prop('disabled', true);
        $('.caption').slideDown(250); //.fadeIn(250)
      },
      done: function(e, data) {
        submitButton.prop('disabled', false);
        // extract key and generate URL from response
        var key   = $(data.jqXHR.responseXML).find("Key").text();
        var url   = 'https://' + form.data('host') + '/litecode.facturacion/' + key;

        // create hidden field
        if (!$('#hidden_photo').length){
          var input = $("<input />", { type:'hidden', name: fileInput.attr('name'), value: url, id: 'hidden_photo' })
        }else {
          $("#hidden_photo").val(url);
        }
        form.append(input);
        $("#image").attr("src", url);
        $('.caption').slideUp(250); //.fadeIn(250)
      },
      fail: function(e, data) {
        submitButton.prop('disabled', false);
      }
    });
  });
})



function populateSelect(data, dropdown){
	select = $("#"+dropdown)
	select.html("")
  console.log(data);
	$.each(data, function(id, d) {
		select.append($("<option />").val(d[0]).text(d[1]));
	});
};

function setProduct(product, index, depot_id){
  $("#"+index).find("input.product_id").val(product["id"]);
  $("#"+index).find("input.code").val(product["code"]);
  $("#"+index).find("input.name").val(product["name"]);
  $("#"+index).find("input.name").prop('title', product["name"]);
  $("#"+index).find("input.price").val(product["net_price"]);
  $("#"+index).find("select.measurement_unit").val(product["measurement_unit"]);
  $("#"+index).find("input.subtotal").val(product["price"]);
  $("#"+index).find("input.supplier_code").val(product["supplier_code"]);
  $("#"+index).find("select.depot_id").val(depot_id);
  $("#"+index).find("input.prodPrice").val(product["cost_price"]).trigger("change");


  subtotal = $("#"+index).find("input.subtotal");
  $("#search_product_modal").modal('hide')
  subtotal.trigger("change");
};
