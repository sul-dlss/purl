var imgInfo;

var sizes = ['small', 'medium', 'large'];
var selectedSize = sizes[0];    
var resizeTimer;

$(document).ready(function() {
  
  // set toggle and links for clickable item header    
  $('ol#toc li > a').each(function () {
    var id = $(this).attr('id');
        
    if (id != '') {
      setToggle(id, id);
      setViewerLinks(id);
    }
  });

  // calculate dimensions for each size and display 
  for (var i = 0; i < imgInfo.length; i++) {
    var id = imgInfo[i]['id'];
    var width = imgInfo[i]['width'];
    var height = imgInfo[i]['height'];
    
    imgInfo[i]['levels'] = calculateLevel(width, height);
    imgInfo[i]['small']  = getDimensions(width, height, imgInfo[i]['levels'], 'small');
    imgInfo[i]['medium'] = getDimensions(width, height, imgInfo[i]['levels'], 'medium');
    imgInfo[i]['large']  = getDimensions(width, height, imgInfo[i]['levels'], 'large');
    
    $('#small-size-' + id).html('(' + imgInfo[i]['small'] + ')');
    $('#medium-size-' + id).html('(' + imgInfo[i]['medium'] + ')');
    $('#large-size-' + id).html('(' + imgInfo[i]['large'] + ')');
  }

  if (imgInfo.length == 1) {
	$('#' + imgInfo[0]['id']).click(); 
  }

  $('#container').height(parseInt($(window).height(), 10) - 10);  
  $('#pane-toc-metadata').height(parseInt($(window).height(), 10) - 80);
  $('#pane-img-viewer').css('left', parseInt($('#pane-toc-metadata').width(), 10));

  $(window).bind('resize',function() {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(reloadPage, 100);
  });

});

// reload page on resize
function reloadPage() {
  location.reload();
};

// set toggle action
function setToggle(elemId, imgId) {
  $('#' + elemId).click(function(){
    if ($('#data-links-' + imgId).is(':visible')) {
      $('a#' + imgId).removeClass('item-header-hide');
      $('#square-img-' + imgId).css('visibility', 'visible');
      $('#data-links-' + imgId).hide();
      $('#full-img-' + imgId).hide();                    
    } else {
      $('a#' + imgId).addClass('item-header-hide');
      $('#square-img-' + imgId).css('visibility', 'hidden');
      $('#data-links-' + imgId).show();
      $('#full-img-' + imgId).fadeIn('fast');      
    }
  });
}


function setViewerLinks(id) {
  var len = sizes.length;  
   
  for (var i = 0; i < len; i++) {      
    $('#' + sizes[i] + '-' + id).click(function() {
      showImg(this.id, id);
    });
  }   

	$('#zoom-' + id).click(function() {
		showImg(this.id, id);
	});
}

function changeDownloadFormat(name) {
  var ext = $('#download-format-' + name).val();    
      
  $('#small-download-' + name).attr({
    'href': replaceHrefExt($('#small-download-' + name).attr('href'), ext),
    'title': replaceTitleExt($('#small-download-' + name).attr('title'), ext)
  });

  $('#medium-download-' + name).attr({
    'href': replaceHrefExt($('#medium-download-' + name).attr('href'), ext),
    'title': replaceTitleExt($('#medium-download-' + name).attr('title'), ext)
  });

  $('#large-download-' + name).attr({
    'href': replaceHrefExt($('#large-download-' + name).attr('href'), ext),
    'title': replaceTitleExt($('#large-download-' + name).attr('title'), ext)
  });
}

function replaceHrefExt(str, ext) {
  str = str.replace(/\.\w+\?action=/, '.' + ext + '?action=');
  return str;
}

function replaceTitleExt(str, ext) {
  str = str.replace(/\.\w+$/, '.' + ext);
  return str;
}


function showImg(elemId, id) {
  var regex = new RegExp('-' + id, 'i');  
  var size = elemId.replace(regex, '');
  var druid = pid;
  var index = getArrayIndex(id);

  if (index < 0) return;

  var imgNumber = parseInt(index, 10) + 1;

  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);
  slideWidth = slideWidth - (2*slideWidth);
  
  $('#pane-toc-metadata').animate({
    'left': slideWidth + 'px'
  }, 500, function() {});
  
  $('#pane-img-viewer').animate({
    'left': 0 + 'px'
  }, 500, function() {
		if (size == 'zoom') {
			loadZpr(id);
		} else {
	    loadImage(id, size);			
		}
  });
  
  $('#small-img-viewer').click(function() { loadImage(id, 'small'); });
  $('#medium-img-viewer').click(function() { loadImage(id, 'medium'); });
  $('#large-img-viewer').click(function() { loadImage(id, 'large'); });
  $('#zoom-img-viewer').click(function() { loadZpr(id); });

  $('#small-img-viewer-id').html(imgNumber);
  $('#medium-img-viewer-id').html(imgNumber);
  $('#large-img-viewer-id').html(imgNumber);
  $('#small-img-viewer-download-id').html(imgNumber);
  $('#medium-img-viewer-download-id').html(imgNumber);
  $('#large-img-viewer-download-id').html(imgNumber);
  
  $('#small-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_small.jpg?action=download',
    'title': 'Download ' + id + '_small.jpg'
  });
  
  $('#medium-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_medium.jpg?action=download',
    'title': 'Download ' + id + '_medium.jpg'
  });
  
  $('#large-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_large.jpg?action=download',
    'title': 'Download ' + id + '_large.jpg'
  });
  
  $('#small-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'small') + ')' );
  $('#medium-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'medium') + ')' );
  $('#large-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'large') + ')' );

	$('#img-viewer-item-label').html('(' +  imgInfo[index]['label'] + ')');
	$('#img-viewer-pagination').html((index + 1) + ' of ' + imgInfo.length);

	if ($('#img-viewer-prev').length != 0 && $('#img-viewer-next').length != 0) {
				
	  $('#img-viewer-prev').addClass('viewer-nav-link-disable');
	  $('#img-viewer-next').addClass('viewer-nav-link-disable');
	  $('#img-viewer-prev').unbind();
	  $('#img-viewer-next').unbind();

	  if ((index - 1) >= 0) {
	    $('#img-viewer-prev').click(function() { prev(id, size); });
	    $('#img-viewer-prev').removeClass('viewer-nav-link-disable');
	  }  
  
	  if ((index + 1) < imgInfo.length) {
	    $('#img-viewer-next').click(function() { next(id, size); });
	    $('#img-viewer-next').removeClass('viewer-nav-link-disable');
	  }		
	}
}

function loadImage(id, size) {
  var druid = pid;
  var index = getArrayIndex(id);

  var url = stacksURL + '/image/' + druid + '/' + id + '_' + size + '.jpg';
  var strDimensions = getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], size);
  var dimensions = strDimensions.match(/(\d+) x (\d+)/);
  var viewfinderHeight = parseInt($(window).height(), 10) - parseInt($('#img-viewer-metadata').height(), 10) - 120;
  var imgWidth = dimensions[1];
  var imgHeight = dimensions[2];

  selectedSize = size;

  $('#zpr-frame').hide();
  $('#img-canvas').show();	

  $('#img-viewfinder').height(viewfinderHeight + 'px');

  $('#img-canvas')
  .removeAttr('src')
  .attr({
    'src': url,    
  })
  .css({
    'height': imgHeight + 'px',       
    'width': imgWidth + 'px'
  });            
}

function changeImgViewerDownloadFormat() {
  var ext = $('#img-viewer-download-format').val();    
      
  $('#small-img-viewer-download').attr({
    'href': replaceHrefExt($('#small-img-viewer-download').attr('href'), ext),
    'title': replaceTitleExt($('#small-img-viewer-download').attr('title'), ext)
  });

  $('#medium-img-viewer-download').attr({
    'href': replaceHrefExt($('#medium-img-viewer-download').attr('href'), ext),
    'title': replaceTitleExt($('#medium-img-viewer-download').attr('title'), ext)
  });

  $('#large-img-viewer-download').attr({
    'href': replaceHrefExt($('#large-img-viewer-download').attr('href'), ext),
    'title': replaceTitleExt($('#large-img-viewer-download').attr('title'), ext)
  });
}


function loadZpr(id) {
  var druid = pid;
  var index = getArrayIndex(id);
  var viewfinderHeight = parseInt($(window).height(), 10) - parseInt($('#img-viewer-metadata').height(), 10) - 120;

  selectedSize = 'zoom';
	
  $('#img-viewfinder').height(viewfinderHeight + 'px');

	$('#img-canvas').hide();
	$('#zpr-frame').show();
	
	$('#zpr-frame').width(($('#img-viewfinder').width() - 20) + 'px');
	$('#zpr-frame').height((viewfinderHeight - 20) + 'px');

	$('#zpr-frame').html('');
	
	var z = new zpr('zpr-frame', { 
		'imageStacksURL': stacksURL + '/image/' + druid + '/' + id, 
		'width': imgInfo[index]['width'], 
		'height': imgInfo[index]['height'], 
		'marqueeImgSize': 150  
	});	
}


function viewTOC() {
  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);
  
  $('#pane-img-viewer').animate({
    'left': slideWidth + 'px'
  }, 500, function() {});
  
  $('#pane-toc-metadata').animate({
    'left': 0 + 'px'
  }, 500, function() {});
}


function getDruid(id) {
  var druid = '';
  
  if (/^[a-z]{2}[0-9]{3}[a-z]{2}[0-9]{4}/.test(id)) {
    druid = id.substr(0, 11);
  }
  
  return druid;  
}

function getArrayIndex(id) {
  for (var i = 0; i < imgInfo.length; i++) {
    if (id == imgInfo[i]["id"]) {
      return i;
    }
  }
  
  return -1;
}

function getPairTree(id) {
	var pairTree = '';
	
  if (/^[a-z]{2}[0-9]{3}[a-z]{2}[0-9]{4}/.test(id)) {
    pairTree = id.substr(0, 2) + '/' + id.substr(2, 3) + '/' + 
			id.substr(5, 2) + '/' + id.substr(7, 4);
  }	

	return pairTree;
}


function getDimensions(width, height, maxLevels, size) {  
  var mappingLevels = {
    'small': parseInt(maxLevels) - 3,
    'medium': parseInt(maxLevels) - 2, 
    'large': parseInt(maxLevels) - 1
  }
      
  var diffLevel = maxLevels - mappingLevels[size];
  
  for (i = 0; i <= diffLevel; i++) {
    width = Math.round(width/2);  
    height = Math.round(height/2);  
  }
  
  var dimension = width + ' x ' + height;
  return dimension;  
}


function prev(id, size) {
  var index = getArrayIndex(id);
  var id = imgInfo[--index]["id"];

  showImg(selectedSize + "-" + id, id);
}


function next(id, size) {
  var index = getArrayIndex(id);
  var id = imgInfo[++index]["id"];

  showImg(selectedSize + "-" + id, id);
}


function calculateLevel(width, height) {
  var level = 0;
  var maxDimension = width > height ? width : height;
  
  while (maxDimension >= 96) {
    ++level;
    maxDimension = Math.round(maxDimension/2);
  }

  return level;
}
