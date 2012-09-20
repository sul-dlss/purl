var imgInfo;

var sizes = ['small', 'medium', 'large', 'xlarge', 'full'];
var selectedSize = sizes[0];    
var resizeTimer;
var groups = [];
var urlSuffix = "";
var gallery = { view: false, pageNo: 1 };

Array.prototype.unique = function() { 
  var o = {}, i, l = this.length, r = [];    
  for(i=0; i<l;i+=1) o[this[i]] = this[i];    
  for(i in o) r.push(o[i]); return r;
};

$(document).ready(function() {
  
  $(window).bind('hashchange', function(){
    setURLSuffix();
  });

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

    imgInfo[i]['thumb']  = getThumbDimensions(id);
    imgInfo[i]['small']  = getDimensions(width, height, imgInfo[i]['levels'], 'small');
    imgInfo[i]['medium'] = getDimensions(width, height, imgInfo[i]['levels'], 'medium');
    imgInfo[i]['large']  = getDimensions(width, height, imgInfo[i]['levels'], 'large');
    imgInfo[i]['xlarge'] = getDimensions(width, height, imgInfo[i]['levels'], 'xlarge');
    imgInfo[i]['full']   = getDimensions(width, height, imgInfo[i]['levels'], 'full');

    groupId = getGroupId(sequence);
    groups.push(groupId);
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
    $('#icon-list-view').attr('src', '/images/icon-list-view-active.png');
    $('#icon-gallery-view').attr('src', '/images/icon-gallery-view-inactive.png');
    $('ol#toc').show();
    $('div#gallery-content').hide();
  });

  $('#icon-gallery-view').click(function() { 
    $('#icon-list-view').attr('src', '/images/icon-list-view-inactive.png');
    $('#icon-gallery-view').attr('src', '/images/icon-gallery-view-active.png');
    $('div#gallery-content').show();
    $('ol#toc').hide();
  });

  $('#footer-show-hide').toggle(
    function() {
      $('#footer-contents').show();
      $('#footer-show-hide').css('background-image', 'url("/images/icon-img-footer-hide.png")');
    }, 
    function () {
      $('#footer-contents').hide();
      $('#footer-show-hide').css('background-image', 'url("/images/icon-img-footer-show.png")');
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
  loadImgsInHorizontalNavigation(id, index);
  loadImgsInVerticalNavigation(id, index); 

  $('#img-viewer-item-label').html('(' +  imgInfo[index]['label'] + ')');
  
  $('#img-viewer-pagination').html((getSequenceIndex(index) + 1) + ' of ' + groups.length);
  
  if ($('#img-viewer-prev').length != 0 && $('#img-viewer-next').length != 0) {        
    $('#img-viewer-prev > img').attr('src', '/images/img-view-group-prev-inactive.png');
    $('#img-viewer-next').unbind().css('cursor', 'default');

    if ((seqIndex - 1) >= 0) {
      $('#img-viewer-prev').click(function() { prev(seqIndex); }).css('cursor', 'pointer');
      $('#img-viewer-prev > img').attr('src', '/images/img-view-group-prev-active.png');
    }  
  
    if ((seqIndex + 1) < groups.length) {
      $('#img-viewer-next').click(function() { next(seqIndex); }).css('cursor', 'pointer');
      $('#img-viewer-next > img').attr('src', '/images/img-view-group-next-active.png');
    }    
  }
}

function loadImage(id, size) {
  var druid = pid;
  var index = getArrayIndex(id);

  if (typeof size === "undefined") {
    size = selectedSize;
  } else {
    selectedSize = size;  
  }	

  $(location).attr('href', '#image/' + imgInfo[index]['sequence'] + '/' + size);
  //$(location).attr('href', getLocationURL(index, size, location) + '#image/' + imgInfo[index]['sequence'] + '/' + size);
  //$(location).attr('href', getLocationURL(index, size, location) + '#image/' + imgInfo[index]['sequence'] + '/' + size);

  if (size == "zoom") {
    loadZpr(id);
    return;
  }

  loadImgsInVerticalNavigation(id, index); 

  var url = stacksURL + '/image/' + druid + '/' + id + '_' + size + '.jpg';
  var strDimensions = getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], size);
  
  if (size == 'thumb') {
    strDimensions = getThumbDimensions(id);
  }

  var dimensions = strDimensions.match(/(\d+) x (\d+)/);
  var viewfinderHeight = parseInt($(window).height(), 10) - parseInt($('#img-viewer-metadata').height(), 10) - 50;
  var imgWidth = dimensions[1];
  var imgHeight = dimensions[2];

  $('#zpr-frame').hide();
  $('#img-canvas').show();  

  $('#pane-img-viewer').height(viewfinderHeight + 'px');  

  $('#img-viewfinder').height((viewfinderHeight - 100) + 'px');
  $('#img-viewfinder').width(($('#pane-img-viewer').width() - 220) + 'px');

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

function loadZpr(id) {
  var druid = pid;
  var index = getArrayIndex(id);
  var viewfinderHeight = parseInt($(window).height(), 10) - parseInt($('#img-viewer-metadata').height(), 10) - 50;

  selectedSize = 'zoom';

  $(location).attr('href', '#image/' + imgInfo[index]['sequence'] + '/zoom');

  $('#pane-img-viewer').height(viewfinderHeight + 'px');  

  $('#img-viewfinder').height((viewfinderHeight - 100) + 'px');
  $('#img-viewfinder').width(($('#pane-img-viewer').width() - 220) + 'px');

  $('#img-canvas').hide();
  $('#zpr-frame').show();
  
  $('#zpr-frame').width(($('#pane-img-viewer').width() - 232) + 'px');  
  $('#zpr-frame').height((viewfinderHeight - 128) + 'px');

  $('#zpr-frame').html('');
  
  var z = new zpr('zpr-frame', { 
    'imageStacksURL': stacksURL + '/image/' + druid + '/' + id, 
    'width': imgInfo[index]['width'], 
    'height': imgInfo[index]['height'], 
    'marqueeImgSize': 50  
  });  
  
  loadImgsInVerticalNavigation(id, index); 
}

function updateViewerSizesLinks(id, index) {
  var druid = pid;
  var imgNumber = parseInt(index, 10) + 1;

  $('#thumb-img-viewer').click(function() { loadImage(id, 'thumb'); });
  $('#small-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(id, 'small'); }});
  $('#medium-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(id, 'medium'); }});
  $('#large-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(id, 'large'); }});
  $('#xlarge-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(id, 'xlarge'); }});
  $('#full-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(id, 'full'); }});
  $('#zoom-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadZpr(id); }});

  $('#thumb-img-viewer-id').html(imgNumber);
  $('#small-img-viewer-id').html(imgNumber);
  $('#medium-img-viewer-id').html(imgNumber);
  $('#large-img-viewer-id').html(imgNumber);
  $('#xlarge-img-viewer-id').html(imgNumber);
  $('#full-img-viewer-id').html(imgNumber);

  $('#thumb-img-viewer-download-id').html(imgNumber);
  $('#small-img-viewer-download-id').html(imgNumber);
  $('#medium-img-viewer-download-id').html(imgNumber);
  $('#large-img-viewer-download-id').html(imgNumber);
  $('#xlarge-img-viewer-download-id').html(imgNumber);
  $('#full-img-viewer-download-id').html(imgNumber);

  $('#thumb-img-viewer-download').attr({
    'href': stacksURL + '/image/' + druid + '/' + id + '_thumb.jpg?action=download',
    'title': 'Download ' + id + '_thumb.jpg'
  });
  
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

  $('#thumb-size-img-viewer').html('(' + getThumbDimensions(imgInfo[index]['id']) + ')' );  
  $('#small-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'small') + ')' );
  $('#medium-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'medium') + ')' );
  $('#large-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'large') + ')' );
  $('#xlarge-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'xlarge') + ')' );
  $('#full-size-img-viewer').html('(' + getDimensions(imgInfo[index]['width'], imgInfo[index]['height'], imgInfo[index]['levels'], 'full') + ')' );
}

function viewTOC() {
  var slideWidth = parseInt($('#pane-toc-metadata').width(), 10);

  if (gallery.view) {
    $(location).attr('href', '#gallery/' + gallery.pageNo);          
  } else {    
    $(location).attr('href', '');
  } 

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
    pairTree = id.substr(0, 2) + '/' + id.substr(2, 3) + '/' + id.substr(5, 2) + '/' + id.substr(7, 4);
  }  

  return pairTree;
}


function getDimensions(width, height, maxLevels, size) {  
  var mappingLevels = {
    'small': parseInt(maxLevels, 10) - 3,
    'medium': parseInt(maxLevels, 10) - 2, 
    'large': parseInt(maxLevels, 10) - 1,
    'xlarge': parseInt(maxLevels, 10) ,
    'full': parseInt(maxLevels, 10) + 1
  }
      
  var diffLevel = maxLevels - mappingLevels[size];
  
  for (i = 0; i <= diffLevel; i++) {
    width = Math.round(width/2);  
    height = Math.round(height/2);  
  }
  
  var dimension = width + ' x ' + height;

  return dimension;  
}


function getThumbDimensions(imgId) {
  var dimensions = getDimensionsToFitBox(400, 400, imgId);
  return dimensions[0] + ' x ' + dimensions[1];
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
  var nextImgId = parseInt(currentImgId, 10) + direction;
  
  if (nextImgId < 1) {
    nextImgId = parseInt(totalImgCount, 10);  
  }
  
  if (nextImgId > parseInt(totalImgCount, 10)) {
    nextImgId = 1;
  }
  
  $('#' + pid + '_seq_' + seqId + '_img_' + currentImgId).hide();
  $('#' + pid + '_seq_' + seqId + '_img_' + nextImgId).show();
  
  return;
}

function loadImgsInHorizontalNavigation(id, index) {
  var druid = pid; 
  var seqIndex = getSequenceIndex(index);
  var i, index, thumbDimensions;
  
  if (seqIndex <= 0) { 
    $('#viewer-h-nav-img-01')
      .attr('src', '/images/img-view-first-ptr.png')
      .css({'cursor': 'auto', 'width': 65, 'height': 40})
      .click(function() {});    
  } else {
    index = getIndexForFirstImgInSequence(seqIndex-1);
    thumbDimensions = getDimensionsToFitBox(65, 40, imgInfo[index]['id']);
    
    $('#viewer-h-nav-img-01')
      .attr('src', stacksURL + '/image/' + druid + '/' + imgInfo[index]["id"] + '_thumb')
      .css({'cursor': 'pointer', 'width': thumbDimensions[0], 'height': thumbDimensions[1]})
      .click(function() { prev(seqIndex); });
  }

  index = getIndexForFirstImgInSequence(seqIndex);
  thumbDimensions = getDimensionsToFitBox(65, 40, imgInfo[index]['id']);
  $('#viewer-h-nav-img-02')
    .attr('src', stacksURL + '/image/' + druid + '/' + imgInfo[index]['id'] + '_thumb')  
    .css({'width': thumbDimensions[0], 'height': thumbDimensions[1] });
  
  if ((seqIndex + 1) == groups.length) {
    $('#viewer-h-nav-img-03')
      .attr('src', '/images/img-view-last-ptr.png')    
      .css({'cursor': 'auto', 'width': 65, 'height': 40})
      .click(function() {});    
  } else {
    index = getIndexForFirstImgInSequence(seqIndex+1);
    thumbDimensions = getDimensionsToFitBox(65, 40, imgInfo[index]['id']);  

    $('#viewer-h-nav-img-03')
      .attr('src', stacksURL + '/image/' + druid + '/' + imgInfo[index]['id'] + '_thumb')      
      .css({ 'cursor': 'pointer', 'width': thumbDimensions[0], 'height': thumbDimensions[1] })
      .click(function() { next(seqIndex); });
  }
  
}

function loadImgsInVerticalNavigation(id, index) {
  var druid = pid;
  var seqIndex = getSequenceIndex(index);  
  var url, height;
  var html = "";      
  
  $('#viewer-v-nav').html('');
  
  for (var i = 0; i < imgInfo.length; i++) {
    if (groups[seqIndex] == getGroupId(imgInfo[i]['sequence'])) {
      url = stacksURL + '/image/' + druid + '/' + imgInfo[i]['id'] + '_thumb';
      height = getAspectRatioBasedHeight(100, imgInfo[i]['id']);
    
      if (index == i) {
        $('#viewer-v-nav').append("<li id=\"viewer-v-nav-selected-img\"><img src=\"" + url  + "\" style=\"width: 100px; height:" + height + "px\"></li>");      
      } else {
        $('#viewer-v-nav').append("<li class=\"viewer-v-nav-img\"><a href=\"javascript:loadImage('" + imgInfo[i]['id'] + "')\"><img src=\"" + url + "\"></a></li>");      
      }
    }  
  }
  
  $('#viewer-v-nav-selected-img').append($('<ul id=\"viewer-sizes-nav\">'));
  
  html = "";
  html = "<li>" + 
    "<div class=\"viewer-sizes-links\">" + 
      "<a id=\"thumb-img-viewer\" href=\"javascript:;\"><span class=\"obscure\">View the</span> thumb <span class=\"obscure\"> size of image </span><span class=\"obscure\" id=\"thumb-img-viewer-id\"></span></a>" +  
      "<span id=\"thumb-size-img-viewer\" class=\"img-size\"></span>" + 
    "</div>" + 
    "<div class=\"viewer-sizes-download\"> " + 
      "<a id=\"thumb-img-viewer-download\">" + 
        "<span class=\"obscure\">Download the thumb size of image </span>" + 
        "<span class=\"obscure\" id=\"thumb-img-viewer-download-id\"></span>" + 
        "<img src=\"/images/icon-download.png\" alt=\"\" title=\"\"/>" + 
      "</a>" + 
    "</div>" + 
  "</li>";    
  $("#viewer-sizes-nav").append(html);

  if (imgInfo[index]['rightsWorld'] === "true") {
    if (imgInfo[index]['rightsStanford'] === "false" && imgInfo[index]['rightsWorldRule'] === "") {
      $.each(sizes, function(i, size) { 
        html = "";
        html = "<li>" + 
          "<div class=\"viewer-sizes-links\">" + 
            "<a id=\"" + size + "-img-viewer\" href=\"javascript:;\"><span class=\"obscure\">View the</span> " + size + " <span class=\"obscure\"> size of image </span><span class=\"obscure\" id=\"" + size + "-img-viewer-id\"></span></a>" +  
            "<span id=\"" + size + "-size-img-viewer\" class=\"img-size\"></span>" + 
          "</div>" + 
          "<div class=\"viewer-sizes-download\"> " + 
            "<a id=\"" + size + "-img-viewer-download\">" + 
              "<span class=\"obscure\">Download the " + size + " size of image </span>" + 
              "<span class=\"obscure\" id=\"" + size +  "-img-viewer-download-id\"></span>" + 
              "<img src=\"/images/icon-download.png\" alt=\"\" title=\"\"/>" + 
            "</a>" + 
          "</div>" + 
        "</li>";    
        
        $("#viewer-sizes-nav").append(html);      
      });
    }  
  }
    
  if (imgInfo[index]['rightsStanford'] === "true") {
    if (imgInfo[index]['rightsStanfordRule'] !== "no-download") { 
      $.each(sizes, function(i, size) { 
        var url = "https://" + $(location).attr('host') + '/auth' +       
          $(location).attr('pathname').replace(/^\/auth/, '') + 
          $(location).attr('hash').replace(/thumb|small|medium|large|xlarge|full|zoom/, size);
      
        html = "";    
        html = "<li>" + 
          "<div class=\"viewer-sizes-links\">" + 
            "<a id=\"" + size + "-img-viewer\" href=\"" + url + "\" class=\"su\"><span class=\"obscure\">View the</span> " + size + " <span class=\"obscure\"> size of image </span><span class=\"obscure\" id=\"" + size + "-img-viewer-id\"></span></a>" +  
            "<span id=\"" + size + "-size-img-viewer\" class=\"img-size\"></span>" + 
          "</div>" + 
          "<div class=\"viewer-sizes-download\"> " + 
            "<a id=\"" + size + "-img-viewer-download\">" + 
              "<span class=\"obscure\">Download the " + size + " size of image </span>" + 
              "<span class=\"obscure\" id=\"" + size +  "-img-viewer-download-id\"></span>" + 
              "<img src=\"/images/icon-download.png\" alt=\"\" title=\"\"/>" + 
            "</a>" + 
            "<img src=\"/images/icon-stanford-only.png\" class=\"icon-stanford-only\" alt=\"Stanford Only\" title=\"Stanford Only\"/>" + 
          "</div>" + 
        "</li>";    
        $("#viewer-sizes-nav").append(html);      
      });        
    }
  }  
    
  if (imgInfo[index]['rightsWorld'] === "true") {
    $("#viewer-sizes-nav").append("<li style=\"float: left;\"><a id=\"zoom-img-viewer\" href=\"javascript:;\" title=\"Zoom View\">zoom<span class=\"obscure\"> of image 1</span></a></li>");                  
  } else if (imgInfo[index]['rightsStanford'] === "true") {
    var url = "https://" + $(location).attr('host') + '/auth' + $(location).attr('pathname').replace(/^\/auth/, '') + $(location).attr('hash').replace(/thumb|small|medium|large|xlarge|full|zoom/, 'zoom');    
    $("#viewer-sizes-nav").append("<li style=\"float: left;\"><a id=\"zoom-img-viewer\" href=\"" + url + "\" class=\"su\" title=\"Zoom View\">zoom<span class=\"obscure\"> of image 1</span></a><img src=\"/images/icon-stanford-only.png\" class=\"icon-stanford-only\" alt=\"Stanford Only\" title=\"Stanford Only\"/></li>");                  
  }    
    
  $("#viewer-sizes-nav").append("</ul>");
  
  updateViewerSizesLinks(id, index);  
}

function setupGalleryPageNavigation(pageNo) {  
  var druid = pid;
  var offset = 3; 
  var elemId, imgId, thumbDimensions;
  var totalPages = $('.gallery').length;
  var startingPageNo = 1, endingPageNo = totalPages;  

  $('.gallery').hide();      
  $('#gallery-page-items-' + pageNo).show();

  $("ol#[id^=gallery-page-items-] img[id^=img-src-]").each(function() { 
    $(this).removeAttr('src');
  });

  $('#gallery-page-items-' + pageNo + " img[id^=img-src-]").each(function() { 
    elemId = this.id;
    imgId = elemId.replace(/^img-src-/, '');
    thumbDimensions = getDimensionsToFitBox(240, 240, imgId);
    $("#" + elemId)
      .attr('src', stacksURL + '/image/' + druid + '/' + imgId + '_thumb')
      .css({'width': thumbDimensions[0], 'height': thumbDimensions[1]}
    );    
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
      setupGalleryPageNavigation(parseInt(galleryPageNo, 10));  
      gallery.view = true;
      gallery.pageNo = galleryPageNo; 
    });       
  });  

  $('#viewer-return-to-label').html('Gallery');
}

function setURLSuffix() {
  var href = $(location).attr('href');
  var match; 
  var pageNo = 1;
  var sequence = 1; 
  var size = "zoom";
  var flag = false;

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
      size = match[3].toLowerCase();
      
      $.each(sizes, function(i, value) {
        if (size == value) { flag = true; }
      });      
    
      if (size == 'thumb') { flag = true; }
    
      if (!flag) { size = "zoom"; }
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

function getAspectRatioBasedHeight(width, imgId) {
  var index = getArrayIndex(imgId);
  var fullWidth = imgInfo[index]['width'];
  var fullHeight = imgInfo[index]['height'];
  var height;

  height = parseInt((fullHeight/fullWidth)*width, 10);
  
  return height;  
}

function getAspectRatioBasedWidth(height, imgId) {
  var index = getArrayIndex(imgId);
  var fullWidth = imgInfo[index]['width'];
  var fullHeight = imgInfo[index]['height'];
  var width;

  width = parseInt((fullWidth/fullHeight)*height, 10);
  
  return width;  
}

function getDimensionsToFitBox(boxWidth, boxHeight, imgId) {
  var index = getArrayIndex(imgId);
  var width, height;

  height = boxHeight;
  width  = getAspectRatioBasedWidth(height, imgId);

  if (width > boxWidth) {
    width  = boxWidth;
    height = getAspectRatioBasedHeight(width, imgId);
  }  

  return [width, height];
}

function getLocationURL(index, size, location) {
	var currentURL = $(location).attr('href');
  var hasAuthString = false;
  var addAuthString = false;

  if (/auth\//.test(currentURL)) {
	  hasAuthString = true;
	}

  if (imgInfo[index]['rightsStanford'] === "true") {
  	addAuthString = true;
  } else if (imgInfo[index]['rightsWorld'] === "true") {
  	addAuthString = false;
  }

  if (size === "thumb") {
  	addAuthString = false;
  }
	
  // add '/auth' string  
  if (addAuthString && !hasAuthString) {
	  currentURL = $(location).attr('origin') + '/auth' + $(location).attr('pathname'); 
	}
	// remove '/auth' string  
	else if (!addAuthString && hasAuthString) { 
		//currentURL = currentURL.replace(/auth\//, '');
		currentURL = $(location).attr('origin') + $(location).attr('pathname').replace(/auth\//, ''); 
	}
	
	return currentURL;
}
