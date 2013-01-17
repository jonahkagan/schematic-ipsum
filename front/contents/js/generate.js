$(document).ready(function () {
  function config(editor) {
    editor.getSession().setMode("ace/mode/json");
    editor.getSession().setTabSize(2);
    editor.renderer.setShowGutter(false);
    editor.setDisplayIndentGuides(false);
    editor.getSession().setUseWrapMode(true);
  }
  var inputEditor = ace.edit("input");
  config(inputEditor);

  var outputEditor = ace.edit("output");
  config(outputEditor);
  outputEditor.setReadOnly(true);

  $("#generate").on("click", function () {
    $("#error").empty()
    try {
      var schema = JSON.parse(inputEditor.getValue());
    } catch (e) {
      console.error(e);
      $("#error").append(e.toString());
      return
    }
    //var schema = JSON.parse($("#input").val());
    var n = $("#input-n").val();
    if (!n) {
      n = 1;
      $("#input-n").val(1);
    }
    console.log(schema);
    $.post(
      "http://schematic-ipsum.herokuapp.com/?n=" + n,
      //"http://localhost:3000?n=" + n,
      schema,
      function (data) {
        console.log(data);
        outputEditor.setValue(data);
        outputEditor.clearSelection();
        //$("#output").val(data);
      }
    ).error(function (err) {
      console.error(err);
      var issuesUrl = "http://github.com/jonahkagan/schematic-ipsum/issues";
      if (!err.responseText) {
        $("#error").append("Something went wrong on the server!" +
                           "Please check the console and if necessary " +
                           "<a href=\"" + issuesUrl + "\">report this issue</a>.")
      } else {
        $("#error").append(err.responseText);
      }
    });
  })
})
