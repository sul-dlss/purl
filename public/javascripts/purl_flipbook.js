$(function() {
  $(window).bind('hashchange', function(){
    setURLSuffix();
  });

  $('#container').height(parseInt($(window).height(), 10) - 10);
  $('#contents').height(parseInt($(window).height(), 10) - 80);

  $('#pane-toc-metadata').height(parseInt($(window).height(), 10) - 80);
  $('#pane-flipbook').css('left', parseInt($('#pane-toc-metadata').width(), 10));

  setURLSuffix();
});


function showFullScreen() {
  var duration = 100;
  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);
  var iframeUrl = 'http://sul-reader.stanford.edu/flipbook2/embed.jsp?id=' + pid;

  slideWidth = slideWidth - (2*slideWidth);

  $('#pane-toc-metadata').animate({
    'left': slideWidth + 'px'
  }, duration, function() {}).hide();

  $('#pane-flipbook').show().animate({
    'left': 0 + 'px'
  }, duration, function() {});

  var flipbookViewerHeight = parseInt($(window).height(), 10) - parseInt($('#fs-flipbook-metadata').height(), 10) - 60;

  $('#pane-flipbook').height(flipbookViewerHeight);

  $('.fs-flipbook-viewer').height((flipbookViewerHeight - 70));
  $('.fs-flipbook-viewer').width(($('#pane-flipbook').width() - 20));

  $('#embed-flipbook').height($('.fs-flipbook-viewer').height());
  $('#embed-flipbook').width($('.fs-flipbook-viewer').width());

  if (typeof $('#embed-flipbook').attr('src') === 'undefined' || $('#embed-flipbook').attr('src') === "") {
    $('#embed-flipbook').attr('src', iframeUrl);
  }

  $(location).attr('href', '#flipbook');
}

function viewTOC() {
  var duration = 100;
  var slideWidth = parseInt($('#pane-flipbook').width(), 10);

  $(location).attr('href', '');

  $('#pane-flipbook').animate({
    'left': slideWidth + 'px'
  }, duration, function() {}).hide();

  $('#pane-toc-metadata').show().animate({
    'left': 0 + 'px'
  }, duration, function() {});
}

function setURLSuffix() {
  var href = $(location).attr('href');

  if (/#flipbook/.test(href)) {
    showFullScreen();
  }
}