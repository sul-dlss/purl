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


function showFullScreen(animate) {
  var duration = 100;
  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);
  var iframeUrl = 'http://sul-reader.stanford.edu/flipbook2/embed.jsp?id=' + pid;

  if (typeof animate !== 'undefined' && !animate) {
    duration = 0;
  } else {
    duration = 100;
  }

  slideWidth = slideWidth - (2*slideWidth);

  $('#pane-toc-metadata').animate({
    'left': slideWidth + 'px'
  }, duration, function() {}).hide();

  $('#pane-flipbook').show().animate({
    'left': 0 + 'px'
  }, duration, function() {});

  var flipbookViewerHeight = $('#pane-toc-metadata').height();

  $('#pane-flipbook').height(flipbookViewerHeight);

  $('.fs-flipbook-viewer').height((flipbookViewerHeight - parseInt($('#fs-flipbook-links').height(), 10) - 40));
  $('.fs-flipbook-viewer').width(($('#pane-flipbook').width() - 20));

  $('#embed-flipbook').height($('.fs-flipbook-viewer').height());
  $('#embed-flipbook').width($('.fs-flipbook-viewer').width());

  if (typeof $('#embed-flipbook').attr('src') === 'undefined' || $('#embed-flipbook').attr('src') === "") {
    $('#embed-flipbook').attr('src', iframeUrl);
  }

  $(location).attr('href', '#flipbook');
}

function viewTOC() {
  var url = purlServerURL + '/' + pid;
  $(location).attr('href', url);
}

function setURLSuffix() {
  var href = $(location).attr('href');

  if (/#flipbook/.test(href)) {
    showFullScreen(false);
  }
}