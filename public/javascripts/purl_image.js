var imgInfo;

var sizes = ['small', 'medium', 'large', 'xlarge', 'full'];
var selectedSize = sizes[0];    
var resizeTimer;
var groups = [];
var urlSuffix = "";

Array.prototype.unique = function() { var o = {}, i, l = this.length, r = [];    for(i=0; i<l;i+=1) o[this[i]] = this[i];    for(i in o) r.push(o[i]); return r;};

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
    var sequence = imgInfo[i]['sequence'];
    var groupId, str;
    
    imgInfo[i]['levels'] = calculateLevel(width, height);

    imgInfo[i]['small']  = getDimensions(width, height, imgInfo[i]['levels'], 'small');
    imgInfo[i]['medium'] = getDimensions(width, height, imgInfo[i]['levels'], 'medium');
    imgInfo[i]['large']  = getDimensions(width, height, imgInfo[i]['levels'], 'large');
    imgInfo[i]['xlarge']  = getDimensions(width, height, imgInfo[i]['levels'], 'xlarge');
    imgInfo[i]['full']  = getDimensions(width, height, imgInfo[i]['levels'], 'full');

    groupId = getGroupId(sequence);
    groups.push(groupId);
    
    $('#small-size-' + id).html('(' + imgInfo[i]['small'] + ')');
    $('#medium-size-' + id).html('(' + imgInfo[i]['medium'] + ')');
    $('#large-size-' + id).html('(' + imgInfo[i]['large'] + ')');
  }

  groups = groups.unique();

  if (imgInfo.length == 1) {
	  $('#' + imgInfo[0]['id']).click(); 
  }

  $('#container').height(parseInt($(window).height(), 10) - 10);  
  $('#contents').height(parseInt($(window).height(), 10) - 80);
  
  $('#pane-toc-metadata').height(parseInt($(window).height(), 10) - 80);
  $('#pane-img-viewer').css('left', parseInt($('#pane-toc-metadata').width(), 10));
  $('#img-viewer-links').width(parseInt($('#pane-toc-metadata').width() - 20, 10));

  $(window).bind('resize',function() {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(reloadPage, 100);
  });

  $('#icon-list-view').click(function() { 
	  $('#icon-list-view').attr('src', 'images/icon-list-view-active.png');
	  $('#icon-gallery-view').attr('src', 'images/icon-gallery-view-inactive.png');
	  $('ol#toc').show();
	  $('div#gallery-content').hide();
  });

  $('#icon-gallery-view').click(function() { 
	  $('#icon-list-view').attr('src', 'images/icon-list-view-inactive.png');
	  $('#icon-gallery-view').attr('src', 'images/icon-gallery-view-active.png');
	  $('div#gallery-content').show();
	  $('ol#toc').hide();
  });

  $('#footer-show-hide').toggle(
	  function() {
	    $('#footer-contents').show();
		  $('#footer-show-hide').css('background-image', 'url("images/icon-img-footer-hide.png")');
	  }, 
	  function () {
		  $('#footer-contents').hide();
		  $('#footer-show-hide').css('background-image', 'url("images/icon-img-footer-show.png")');
    }
  );

  setupGalleryPageNavigation(1);
  setURLSuffix();
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


function showImg(sequence, size, animate) {
  var druid = pid;
  var index = getArrayIndexUsingSequence(sequence);
  var id = imgInfo[index]["id"];
  var seqIndex = getSequenceIndex(index);
  var duration = 400;

  if (typeof animate === 'undefined' || animate == false) {
	  duration = 0;
  }

  if (index < 0) return;

  var imgNumber = parseInt(index, 10) + 1;

  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);
  slideWidth = slideWidth - (2*slideWidth);
  
  $('#pane-toc-metadata').animate({
    'left': slideWidth + 'px'
  }, 500, function() {});
  
  $('#pane-img-viewer').animate({
    'left': 0 + 'px'
  }, duration, function() {
		if (size == 'zoom') {
			loadZpr(id);
		} else {
	    loadImage(id, size);			
		}
  });
  
  selectedSize = size;

  $('#small-img-viewer').click(function() { loadImage(id, 'small'); });
  $('#medium-img-viewer').click(function() { loadImage(id, 'medium'); });
  $('#large-img-viewer').click(function() { loadImage(id, 'large'); });
  $('#xlarge-img-viewer').click(function() { loadImage(id, 'xlarge'); });
  $('#full-img-viewer').click(function() { loadImage(id, 'full'); });
  $('#zoom-img-viewer').click(function() { loadZpr(id); });

  $('#small-img-viewer-id').html(imgNumber);
  $('#medium-img-viewer-id').html(imgNumber);
  $('#large-img-viewer-id').html(imgNumber);
  $('#xlarge-img-viewer-id').html(imgNumber);
  $('#full-img-viewer-id').html(imgNumber);

  $('#small-img-viewer-download-id').html(imgNumber);
  $('#medium-img-viewer-download-id').html(imgNumber);
  $('#large-img-viewer-download-id').html(imgNumber);
  $('#xlarge-img-viewer-download-id').html(imgNumber);
  $('#full-img-viewer-download-id').html(imgNumber);
  
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

  $('#xlarge-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_xlarge.jpg?action=download',
    'title': 'Download ' + id + '_xlarge.jpg'
  });

  $('#full-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_full.jpg?action=download',
    'title': 'Download ' + id + '_full.jpg'
  });
  
  $('#small-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'small') + ')' );
  $('#medium-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'medium') + ')' );
  $('#large-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'large') + ')' );
  $('#xlarge-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'xlarge') + ')' );
  $('#full-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'full') + ')' );

	$('#img-viewer-item-label').html('(' +  imgInfo[index]['label'] + ')');
	
	$('#img-viewer-pagination').html((getSequenceIndex(index) + 1) + ' of ' + groups.length);
	
  loadImgsInHorizontalNavigation(id, index);
  loadImgsInVerticalNavigation(id, index); 

	if ($('#img-viewer-prev').length != 0 && $('#img-viewer-next').length != 0) {				
	  $('#img-viewer-prev > img').attr('src', 'images/img-view-group-prev-inactive.png');
	  $('#img-viewer-next > img').attr('src', 'images/img-view-group-next-inactive.png');	  
	  $('#img-viewer-prev').unbind().css('cursor', 'default');
	  $('#img-viewer-next').unbind().css('cursor', 'default');

	  if ((seqIndex - 1) >= 0) {
	    $('#img-viewer-prev').click(function() { prev(seqIndex); }).css('cursor', 'pointer');
		  $('#img-viewer-prev > img').attr('src', 'images/img-view-group-prev-active.png');
	  }  
  
	  if ((seqIndex + 1) < groups.length) {
	    $('#img-viewer-next').click(function() { next(seqIndex); }).css('cursor', 'pointer');
		  $('#img-viewer-next > img').attr('src', 'images/img-view-group-next-active.png');
	  }		
	}
}


/*function showImg(elemId, id) {
  var regex = new RegExp('-' + id + '.*', 'i');  
  var size = elemId.replace(regex, '');
  var druid = pid;
  var index = getArrayIndex(id);
  var seqIndex = getSequenceIndex(index);

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
  
  selectedSize = size;

  $('#small-img-viewer').click(function() { loadImage(id, 'small'); });
  $('#medium-img-viewer').click(function() { loadImage(id, 'medium'); });
  $('#large-img-viewer').click(function() { loadImage(id, 'large'); });
  $('#xlarge-img-viewer').click(function() { loadImage(id, 'xlarge'); });
  $('#full-img-viewer').click(function() { loadImage(id, 'full'); });
  $('#zoom-img-viewer').click(function() { loadZpr(id); });

  $('#small-img-viewer-id').html(imgNumber);
  $('#medium-img-viewer-id').html(imgNumber);
  $('#large-img-viewer-id').html(imgNumber);
  $('#xlarge-img-viewer-id').html(imgNumber);
  $('#full-img-viewer-id').html(imgNumber);

  $('#small-img-viewer-download-id').html(imgNumber);
  $('#medium-img-viewer-download-id').html(imgNumber);
  $('#large-img-viewer-download-id').html(imgNumber);
  $('#xlarge-img-viewer-download-id').html(imgNumber);
  $('#full-img-viewer-download-id').html(imgNumber);
  
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

  $('#xlarge-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_xlarge.jpg?action=download',
    'title': 'Download ' + id + '_xlarge.jpg'
  });

  $('#full-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_full.jpg?action=download',
    'title': 'Download ' + id + '_full.jpg'
  });
  
  $('#small-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'small') + ')' );
  $('#medium-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'medium') + ')' );
  $('#large-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'large') + ')' );
  $('#xlarge-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'xlarge') + ')' );
  $('#full-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'full') + ')' );

	$('#img-viewer-item-label').html('(' +  imgInfo[index]['label'] + ')');
	
	$('#img-viewer-pagination').html((getSequenceIndex(index) + 1) + ' of ' + sequences.length);
	
  loadImgsInHorizontalNavigation(id, index);
  loadImgsInVerticalNavigation(id, index); 

	if ($('#img-viewer-prev').length != 0 && $('#img-viewer-next').length != 0) {
				
	  $('#img-viewer-prev > img').attr('src', 'images/img-view-group-prev-inactive.png');
	  $('#img-viewer-next > img').attr('src', 'images/img-view-group-next-inactive.png');	  
	  $('#img-viewer-prev').unbind().css('cursor', 'default');
	  $('#img-viewer-next').unbind().css('cursor', 'default');

	  if ((seqIndex - 1) >= 0) {
	    $('#img-viewer-prev').click(function() { prev(id, size, seqIndex); }).css('cursor', 'pointer');
		  $('#img-viewer-prev > img').attr('src', 'images/img-view-group-prev-active.png');
	  }  
  
	  if ((seqIndex + 1) < sequences.length) {
	    $('#img-viewer-next').click(function() { next(id, size, seqIndex); }).css('cursor', 'pointer');
		  $('#img-viewer-next > img').attr('src', 'images/img-view-group-next-active.png');
	  }		
	}
}
*/

function loadImage(id, size) {
  var druid = pid;
  var index = getArrayIndex(id);

  if (typeof size === "undefined") {
	  size = selectedSize;
  } else {
	  selectedSize = size;	
  }

  $(location).attr('href', '#image/' + imgInfo[index]['sequence'] + '/' + size);

  if (size == "zoom") {
	  loadZpr(id);
	  return;
  }

  var url = stacksURL + '/image/' + druid + '/' + id + '_' + size + '.jpg';
  var strDimensions = getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], size);
  var dimensions = strDimensions.match(/(\d+) x (\d+)/);
  var viewfinderHeight = parseInt($(window).height(), 10) - parseInt($('#img-viewer-metadata').height(), 10) - 50;
  var imgWidth = dimensions[1];
  var imgHeight = dimensions[2];

  $('#zpr-frame').hide();
  $('#img-canvas').show();	

  $('#pane-img-viewer').height(viewfinderHeight + 'px');  

  $('#img-viewfinder').height((viewfinderHeight - 130) + 'px');
  $('#img-viewfinder').width(($('#pane-img-viewer').width() - 140) + 'px');

  $('#img-canvas')
  .removeAttr('src')
  .attr({
    'src': url,    
  })
  .css({
    'height': imgHeight + 'px',       
    'width': imgWidth + 'px'
  });            

  loadImgsInVerticalNavigation(id, index); 
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
  var viewfinderHeight = parseInt($(window).height(), 10) - parseInt($('#img-viewer-metadata').height(), 10) - 50;

  selectedSize = 'zoom';

  $(location).attr('href', '#image/' + imgInfo[index]['sequence'] + '/zoom');

  $('#pane-img-viewer').height(viewfinderHeight + 'px');  

  $('#img-viewfinder').height((viewfinderHeight - 130) + 'px');
  $('#img-viewfinder').width(($('#pane-img-viewer').width() - 140) + 'px');

	$('#img-canvas').hide();
	$('#zpr-frame').show();
	
  $('#zpr-frame').width(($('#pane-img-viewer').width() - 160) + 'px');	
	$('#zpr-frame').height((viewfinderHeight - 145) + 'px');

	$('#zpr-frame').html('');
	
	var z = new zpr('zpr-frame', { 
		'imageStacksURL': stacksURL + '/image/' + druid + '/' + id, 
		'width': imgInfo[index]['width'], 
		'height': imgInfo[index]['height'], 
		'marqueeImgSize': 150  
	});	
	
	loadImgsInVerticalNavigation(id, index); 
}


function viewTOC() {
  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);
  
  $(location).attr('href', '#');

  $('#pane-img-viewer').animate({
    'left': slideWidth + 'px'
  }, 400, function() {});
  
  $('#pane-toc-metadata').animate({
    'left': 0 + 'px'
  }, 400, function() {});
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

function getArrayIndexUsingSequence(sequence) {
  for (var i = 0; i < imgInfo.length; i++) {
    if (sequence == imgInfo[i]["sequence"]) {
      return i;
    }
  }
  
  return -1;
}


function getSequenceIndex(index) {
	var sequence = imgInfo[index]["sequence"];
	var groupId = getGroupId(sequence); 
	
  for (var i = 0; i < groups.length; i++) {
    if (groupId == groups[i]) {
      return i;
    }
  }
  
  return -1;
}

function getGroupId(sequence) {
  var groupId;	
	var str = sequence.toString().split(/\./);
  groupId = str[0];
  
  return groupId;
}


function getIndexForFirstImgInSequence(index) {
  for (var i = 0; i < imgInfo.length; i++) {
	  var sequence = imgInfo[i]['sequence'];
	
    if (groups[index] == getGroupId(sequence)) {
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
    'large': parseInt(maxLevels) - 1,
    'xlarge': parseInt(maxLevels) ,
    'full': parseInt(maxLevels) + 1
  }
      
  var diffLevel = maxLevels - mappingLevels[size];
  
  for (i = 0; i <= diffLevel; i++) {
    width = Math.round(width/2);  
    height = Math.round(height/2);  
  }
  
  var dimension = width + ' x ' + height;
  return dimension;  
}


function prev(seqIndex) {
  var index = getIndexForFirstImgInSequence(seqIndex - 1);
  var sequence = imgInfo[index]['sequence'];

  showImg(sequence, selectedSize);
}


function next(seqIndex) {
  var index = getIndexForFirstImgInSequence(seqIndex + 1);
  var sequence = imgInfo[index]['sequence'];

  showImg(sequence, selectedSize);
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


function showGalleryImg(currentImgId, totalImgCount, pid, seqId, direction) {
	var nextImgId = parseInt(currentImgId) + direction;
	
	if (nextImgId < 1) {
	  nextImgId = parseInt(totalImgCount);	
	}
	
	if (nextImgId > parseInt(totalImgCount)) {
		nextImgId = 1;
	}
	
	$('#' + pid + '_seq_' + seqId + '_img_' + currentImgId).hide();
	$('#' + pid + '_seq_' + seqId + '_img_' + nextImgId).show();
	
	return;
}

function loadImgsInHorizontalNavigation(id, index) {
	var druid = pid; 
	var seqIndex = getSequenceIndex(index);
	var i;
	
	if (seqIndex <= 0) { 
    $('#viewer-h-nav-img-01').attr('src', 'images/img-view-first-ptr.png');		
	} else {
		$('#viewer-h-nav-img-01')
		  .attr('src', stacksURL + '/image/' + druid + '/' + imgInfo[getIndexForFirstImgInSequence(seqIndex-1)]["id"] + '?w=65&h=40')
		  .css('cursor', 'pointer')
		  .click(function() { prev(seqIndex); });
	}

	$('#viewer-h-nav-img-02').attr('src', stacksURL + '/image/' + druid + '/' + imgInfo[getIndexForFirstImgInSequence(seqIndex)]["id"] + '?w=65&h=40');		
	
	if ((seqIndex + 1) == groups.length) {
		$('#viewer-h-nav-img-03').attr('src', 'images/img-view-last-ptr.png');		
  } else {
	  $('#viewer-h-nav-img-03')
	    .attr('src', stacksURL + '/image/' + druid + '/' + imgInfo[getIndexForFirstImgInSequence(seqIndex+1)]["id"] + '?w=65&h=40')
		  .css('cursor', 'pointer')
		  .click(function() { next(seqIndex); });
  }
	
}

function loadImgsInVerticalNavigation(id, index) {
	var druid = pid;
	var seqIndex = getSequenceIndex(index);	
	var url;
	
	$('#viewer-v-nav').html('');
	
	for (var i = 0; i < imgInfo.length; i++) {
	  if (groups[seqIndex] == getGroupId(imgInfo[i]['sequence'])) {
		  url = stacksURL + '/image/' + druid + '/' + imgInfo[i]["id"] + '?w=100';
		
		  if (index == i) {
			  $('#viewer-v-nav').append("<img src=\"" + url + "\" class=\"viewer-selected-img\">");			
		  } else {
			  $('#viewer-v-nav').append("<a href=\"javascript:loadImage('" + imgInfo[i]["id"] + "')\"><img src=\"" + url + "\"></a>");			
		  }
	  }	
	}
}

function setupGalleryPageNavigation(pageNo) {	
	var druid = pid;
	var offset = 3; 
  var totalPages = $('.gallery').length;
  var startingPageNo = 1, endingPageNo = totalPages;

  $('.gallery').hide();		  
  $('#gallery-page-items-' + pageNo).show();

  $("ol#[id^=gallery-page-items-] img[id^=img-src-]").each(function() { 
	  $(this).removeAttr('src');
	});

	$('#gallery-page-items-' + pageNo + " img[id^=img-src-]").each(function() { 
		var img_id = this.id;
		img_id = img_id.replace(/^img-src-/, '');
		this.src = stacksURL + '/image/' + druid + '/' + img_id + '?w=240&h=240';
	});

	if (totalPages == 1) { return; }
		
  if (pageNo > offset) { startingPageNo = pageNo - offset; }
  if ((pageNo + offset) > totalPages) { startingPageNo = totalPages - (2 * offset); }

  if (startingPageNo < 1) { startingPageNo = 1; }
  if (startingPageNo > totalPages) { startingPageNo = totalPages; }

   endingPageNo = startingPageNo + (2 * offset);

   if (endingPageNo > totalPages) { endingPageNo = totalPages; }

  $('#gallery-pagination').empty();

  if (startingPageNo != 1) {
	  $('#gallery-pagination').append(' ... ');
  }
  
  for (i = startingPageNo; i <= endingPageNo; i++) {
    if (i == pageNo) {
      $('#gallery-pagination').append("<a class=\"gallery-page-nav-link gallery-page-nav-active\" id=\"gallery-page-nav-" + i + "\" href=\"javascript:;\">" + i + "</a>"); 		
    } else {
      $('#gallery-pagination').append("<a class=\"gallery-page-nav-link\" id=\"gallery-page-nav-" + i + "\" href=\"javascript:;\">" + i + "</a>"); 				
    }
  }

  if (endingPageNo != totalPages) {
	  $('#gallery-pagination').append(' ... ');
  }		
	
	$('.gallery-page-nav-link').each(function(){
		var galleryPageNo = this.id;
		galleryPageNo = galleryPageNo.replace(/^gallery-page-nav-/, '');
		
		$('#gallery-page-nav-' + galleryPageNo).click(function() {	
	    $(location).attr('href', '#gallery/' + galleryPageNo);		
	    setupGalleryPageNavigation(parseInt(galleryPageNo)); 	
		});   		
	});	
}

function setURLSuffix() {
	var href = $(location).attr('href');
  var match; 
  var pageNo = 1;
  var sequence = 1; 
  var size = "zoom";

  if (/#gallery/.test(href)) {
	  match = /#gallery\/(\d+)/.exec(href);
	  pageNo = match[1];
	  setupGalleryPageNavigation(validateGalleryPageNo(pageNo));
	}

  if (/#image/.test(href)) {
	  match = /#image\/([0-9]+(\.[0-9]+)?)\/?(\w+)?/.exec(href);	 

	  if (typeof match[1] !== 'undefined' && match[1].length > 0) { 
		  sequence = match[1];
		}  

	  if (typeof match[3] !== 'undefined' && match[3].length > 0) { 
		  size = match[3];
		}  
		
		showImg(sequence, size, false);
	}
}

function validateGalleryPageNo(pageNo) {
	var totalPages = $('.gallery').length;
	pageNo = parseInt(pageNo, 10);
	
	if (pageNo <= 0) { 
		pageNo = 1; 
	}
	
	if (pageNo > totalPages) {
		pageNo = totalPages;
	}
	
	return pageNo;
}