import ace from 'ace-builds';

$(document).ready(function(){

  if ($('#mods').length > 0) {
    var editor = ace.edit("mods");
    editor.setTheme("ace/theme/monokai");
    editor.getSession().setMode("ace/mode/xml");
    $('#mods').css('fontSize', '16px');

    var textarea = $('textarea[name="mods"]');
    textarea.hide();
    editor.getSession().setValue(textarea.val());

    editor.getSession().on('change', function(){
      textarea.val(editor.getSession().getValue());
    });
  }

  $("a[href='#examples']").on('click', function(e){
    e.preventDefault();
    $("#examples").toggle();
  });
});
