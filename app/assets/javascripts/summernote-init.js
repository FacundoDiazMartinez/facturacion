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
      // ['style', ['style']],
      // ['style', ['bold', 'italic', 'underline', 'clear']],
      ['undo', ['undo', 'redo']],
      // ['font', ['font']],
      // ['fontsize', ['fontsize']],
      ['color', ['color']],
      // ['hr', ['hr']],
      ['para', ['ul', 'ol', 'paragraph']],
      // ['height', ['height']],
      // ['table', ['table']],
      // ['link', ['link']],
      // ['fullscreen', ['fullscreen']],
      // ['codeview', ['codeview']]
    ],
    popover: {
      air: [
        ['color', ['color']],
        ['font', ['bold', 'underline', 'clear']]
      ]
    },
    airMode: false,
    placeholder: 'Ingrese su texto aquí...',
    disableDragAndDrop: true,
    lang: 'es-ES',
    height: 150,
    maxHeight: 150,
    disableResizeEditor: true,
    callbacks: {
      onKeydown: function(e) {
        var t = e.currentTarget.innerText;

        t.split(/\n/).forEach(function(line){  //Limite por cada linea
          if (line.length > 230) {
            if (e.keyCode != 7)
              e.preventDefault();
          }
        });

        if (t.split(/\n/).length > 5) { // Limite cantidad de lineas
          if (e.keyCode != 8)
            e.preventDefault();
        }

        // if (t.trim().length >= 400) { // Limite cantidad de caracteres
        //   //delete key
        //   if (e.keyCode != 8)
        //     e.preventDefault();
        //   // add other keys ...
        // }
      }
    }
  });
}

// Se editó con summerno-toolbar.scss la altura del toolbar para que no tenga problemas con los datepickers del formulario
