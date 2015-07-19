//= require footer

$(function() {
  $('#full-screen-close').click(function() {
	  $('#full-screen-book').hide();
	  $('#full-screen-embed').empty();
  });

});

function ffs() {
	$("#full-screen-embed").append("<iframe src=\"http://sul-reader.stanford.edu/flipbook2/embed.jsp?id=" + pid + "\"" + " width=\"98%\" height=\"100%\" style=\"background-color:#fff; padding: 0; margin: 0; z-index: 5000;\" ></iframe>");
  $("#full-screen-book").show();
}