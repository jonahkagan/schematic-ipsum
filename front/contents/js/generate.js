$(document).ready(function () {
  var inputEditor = ace.edit("input");
  inputEditor.getSession().setMode("ace/mode/json");
  inputEditor.renderer.setShowGutter(false);
  inputEditor.setDisplayIndentGuides(false);
  inputEditor.getSession().setUseWrapMode(true);

  var outputEditor = ace.edit("output");
  outputEditor.getSession().setMode("ace/mode/json");
  outputEditor.setReadOnly(true);
  outputEditor.renderer.setShowGutter(false);
  outputEditor.setDisplayIndentGuides(false);
  outputEditor.getSession().setUseWrapMode(true);

  $("#generate").on("click", function () {
    $("#error").empty()
    var schema = JSON.parse(inputEditor.getValue());
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
