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

//= require jquery_nested_form
//= require invoices
//= require users
//= require popper
//= require bootstrap
//= require bootstrap-toggle
//= require z.jquery.fileupload
//= require activestorage
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.es.js
//= require_tree .
//= require autocomplete-rails

$(document).ready(function() {

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

  $("#image").on("click", function(){
    document.getElementById('file_input').click();
  })

  $(':input[type="number"]').attr('pattern', "[0-9]+([\.,][0-9]+)?").attr('step', 'any');
  $('.toogle').bootstrapToggle();
  $('.datepicker').datepicker({
      language: "es",
      dateFormat: "dd/mm/yyyy",
      todayHighlight: true,
      autoclose: true,
  });
});

function remoteSubmit(form_id){
  form = $(form_id);
  $.get(form.attr("action"), form.serialize(), null, "script");
};

$(function() {
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
