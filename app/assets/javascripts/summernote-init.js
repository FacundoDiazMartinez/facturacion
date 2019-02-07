$(document).on('ready',function(){
  loadSummernote();
})

$(document).on('pjax:complete', function() {
  loadSummernote();
})

function loadSummernote(){
  $('.summernote').summernote({
    toolbar: [
    // [groupName, [list of button]]
    ['style', ['style']],
    ['style', ['bold', 'italic', 'underline', 'clear']],
    ['undo', ['undo', 'redo']],
    ['font', ['font']],
    ['fontsize', ['fontsize']],
    ['color', ['color']],
    ['hr', ['hr']],
    ['para', ['ul', 'ol', 'paragraph']],
    ['height', ['height']],
    ['table', ['table']],
    ['link', ['link']],
    ['fullscreen', ['fullscreen']],
    ['codeview', ['codeview']]
  ],
  popover: {
    air: [
      ['color', ['color']],
      ['font', ['bold', 'underline', 'clear']]
    ]
  },
  airMode: false,
  placeholder: 'Confeccione su publicidad aquí...',
  disableDragAndDrop: true,
  lang: 'es-ES',
  height: 336
  });
}

// Se editó con summerno-toolbar.scss la altura del toolbar para que no tenga problemas con los datepickers del formulario
