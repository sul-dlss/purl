/* Function to make an array unique */
Array.prototype.unique = function() { 
  var o = {}, i, l = this.length, r = [];    
  for (i = 0; i < l; i = i+1) o[this[i]] = this[i];    
  for (i in o) r.push(o[i]); return r;
};

$(function() {
  var pe = new purlEmbed(newImgInfo);
});

/* Main purlEmbed function comprising private variables and methods */
var purlEmbed = (function(data) {
  var imgData, currentSequence, druid;
  var groups = [];
  var constants = { 'djatokaBaseResolution': 92, 'thumbSize': 400 };
  var currentSize = 'thumb';
  var sizes = [ 'thumb', 'small', 'medium', 'large', 'xlarge', 'full' ];
  var views = [ 'zoom' ];
  var sizeLevelMapping = { 'small':  -3, 'medium': -2, 'large': -1, 'xlarge': 0,'full': 1 };
  var limits = {
    'non-restricted': ['thumb'],
    'restricted': ['small', 'medium', 'large', 'xlarge', 'full', 'zoom']
  };
  
  /* Constructor function */
  function init() {
    if (typeof data !== 'undefined') {
      imgData = data;  
      console.log(imgData);

      setProperties();        
      showImg(imgData[0].sequence, currentSize);
    }  
  }

  /* Calculate properties for each file and store them in JSON data object */
  function setProperties() {    
    $.each(imgData, function(index, imgObj) {
      var seq = imgObj.sequence;
      var levels = getJP2NumOfLevels(imgObj.width, imgObj.height);     
      var groupId = parseInt(getGroupIdFromSequence(imgObj['sequence']), 10);

      imgData[index].numLevels = levels;
      imgData[index].aspectRatio = parseFloat(imgObj['width']/imgObj['height']).toFixed(2);        
      imgData[index].groupId = groupId;

      groups.push(groupId);
      
      $.each(sizes, function(j, size) {
        return (function(s) {
          imgData[index][s] = getDimensionsForSize(index, s);
          imgData[index]['level-for-' + s] = getLevelForSize(s, index);            
        })(size);
      });      
    });

    druid = pid;
    groups.unique(); // clear duplicate group ids   
  }

  /* show image for a given sequence and size */
  function showImg(sequence, size) {
    var index = getArrayIndexUsingSequence(sequence);
    var id = imgInfo[index].id;
    var seqIndex = getSequenceIndex(index);
    var imgNumber;

    if (index < 0) return;
    
    currentSize = size;
    imgNumber = parseInt(index, 10) + 1;

    if (size === 'zoom') {
      //loadZpr(id);
    } else {
      //loadImage(id, size);      
    }

    loadImgsInHorizontalNavigation(index);
    //loadImgsInVerticalNavigation(index); 

    $('.pe-h-nav-pagination').html((getSequenceIndex(index) + 1) + ' of ' + groups.length);
    setHorizontalNavigationLinks(seqIndex);
  }

  /* Load images in horizontal navigation bar */
  function loadImgsInHorizontalNavigation(index) {
    var seqIndex = getSequenceIndex(index);
    var i, index, thumbDimensions;
    
    if (seqIndex <= 0) { 
      $('.pe-h-nav-img-01')
        .attr('src', '/images/img-view-first-ptr.png')
        .addClass('pe-h-nav-empty-img')
        .click(function() {});    
    } else {
      index = getIndexForFirstImgInSequence(seqIndex-1);
      thumbDimensions = getDimensionsToFitBox(65, 40, index);
      
      $('.pe-h-nav-img-01')
        .attr('src', getImgStacksURL(index, 'thumb'))
        .addClass('pe-cursor-pointer')
        .css({'width': thumbDimensions[0], 'height': thumbDimensions[1]})
        .click(function() { prev(seqIndex); });
    }

    index = getIndexForFirstImgInSequence(seqIndex);
    thumbDimensions = getDimensionsToFitBox(65, 40, index);

    $('.pe-h-nav-img-02')
      .attr('src', getImgStacksURL(index, 'thumb'))
      .css({'width': thumbDimensions[0], 'height': thumbDimensions[1] });
    
    if ((seqIndex + 1) == groups.length) {
      $('.pe-h-nav-img-03')
        .attr('src', '/images/img-view-last-ptr.png')    
        .addClass('pe-h-nav-empty-img')
        .click(function() {});    
    } else {
      index = getIndexForFirstImgInSequence(seqIndex+1);
      thumbDimensions = getDimensionsToFitBox(65, 40, index);  

      $('.pe-h-nav-img-03')
        .attr('src', getImgStacksURL(index, 'thumb'))
        .addClass('pe-cursor-pointer')
        .css({ 'width': thumbDimensions[0], 'height': thumbDimensions[1] })
        .click(function() { next(seqIndex); });
    }    
  }

  /* Enable/disable navigation links for horizontal navigation */
  function setHorizontalNavigationLinks(seqIndex) {    
    if ($('.pe-h-nav-prev').length != 0 && $('.pe-h-nav-next').length != 0) {        

      $('.pe-h-nav-prev > img').attr('src', '/images/img-view-group-prev-inactive.png');
      $('.pe-h-nav-next').unbind().css('cursor', 'default');

      if ((seqIndex - 1) >= 0) {
        $('.pe-h-nav-prev')
          .click(function() { prev(seqIndex); })
          .addClass('pe-cursor-pointer');

        $('.pe-h-nav-prev > img')
          .attr('src', '/images/img-view-group-prev-active.png');
      }  
    
      if ((seqIndex + 1) < groups.length) {
        $('.pe-h-nav-next')
          .click(function() { next(seqIndex); })
          .addClass('pe-cursor-pointer');

        $('.pe-h-nav-next > img')
          .attr('src', '/images/img-view-group-next-active.png');
      }    
    }
  }

  /* Load images in vertical navigation bar */
  function loadImgsInVerticalNavigation(index) {
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



  /* Calculate number of levels for a given JP2 height and width */
  function getJP2NumOfLevels(width, height) {
    var level = 0;
    var longestSideDimension = width > height ? width : height;

    while (longestSideDimension >= constants.djatokaBaseResolution) {
      ++level;
      longestSideDimension = Math.round(longestSideDimension/2);
    }
  
    return level;
  }

  /* Get dimensions for a given size (thumb, small etc.) */
  function getDimensionsForSize(imgIndex, size) {  
    var wxh; 
    var imgObj = imgData[imgIndex];
    var width  = imgObj.width;
    var height = imgObj.height;
    var levelDiff = imgObj.numLevels - getLevelForSize(size, imgIndex);
    
    // 'thumb': fixed length on longest side, no dependency on JP2 levels
    if (size === 'thumb') {
      return getDimensionsForThumb(imgIndex);
    }

    for (i = 0; i <= levelDiff; i++) {
      width = Math.round(width/2);  
      height = Math.round(height/2);  
    }

    return {'width': width, 'height': height};
  }

  /* Calculate aspect-ratio based width for a given height */
  function getAspectRatioBasedWidth(height, imgIndex) {
    var imgObj = imgData[imgIndex];     
    var aspectRatio = parseFloat(imgObj.aspectRatio);

    return parseInt(aspectRatio * height, 10);
  }

  /* Calculate aspect-ratio based height for a given width */
  function getAspectRatioBasedHeight(width, imgIndex) {
    var imgObj = imgData[imgIndex]; 
    var aspectRatio = parseFloat(imgObj.aspectRatio);  
    return parseInt((1 / aspectRatio) * width, 10);
  }

  /* Get aspect-based width and height to fit in a given box dimensions */
  function getDimensionsToFitBox(boxWidth, boxHeight, imgIndex) {
    var height = parseInt(boxHeight, 10);
    var width  = getAspectRatioBasedWidth(height, imgIndex);    

    if (width > boxWidth) {
      width  = parseInt(boxWidth, 10);
      height = getAspectRatioBasedHeight(width, imgIndex);
    }  

    return [width, height];
  }

  /* Get image array index for a given image id from JSON image object */
  function getArrayIndex(imgId) {
    $.each(imgData, function(index, imgObj) {
      if (imgId === imgObj.id) { return i; }        
    });        
    return -1;
  }

  /* Get image array index for a given seauence value from JSON image object */
  function getArrayIndexUsingSequence(sequence) {
    for (var i = 0; i < imgData.length; i++) {
      if (sequence == imgData[i].sequence) {
        return i;
      }
    }    
    return -1;
  }

  /* Get sequence index for a given image index */
  function getSequenceIndex(index) {
    var sequence = imgData[index].sequence;
    var groupId  = getGroupId(sequence); 
    
    for (var i = 0; i < groups.length; i++) {
      if (groupId == groups[i]) {
        return i;
      }
    }
    
    return -1;
  }

  /* Get group id for a given sequence */
  function getGroupId(sequence) {
    var groupId;  
    var str = sequence.toString().split(/\./);
    groupId = str[0];
    
    return groupId;
  }

  /* Get image index for first image in sequence */
  function getIndexForFirstImgInSequence(index) {
    for (var i = 0; i < imgInfo.length; i++) {
      var sequence = imgInfo[i]['sequence'];
    
      if (groups[index] == getGroupId(sequence)) {
        return i;
      }
    }    
    return -1;  
  }


  /* Get dimensions for size 'thumb' */
  function getDimensionsForThumb(imgIndex) {
    var thumbSize = parseInt(constants.thumbSize, 10);
    var dimensions = getDimensionsToFitBox(thumbSize, thumbSize, imgIndex);

    return { 'width': dimensions[0], 'height': dimensions[1] };
  }


  /*  Get level for a given size */
  function getLevelForSize(size, imgIndex) {
    var imgObj = imgData[imgIndex];
    var level = 0;
  
    // thumb has fixed size (refer 'constants.thumbSize')  
    if (size !== 'thumb') {
      level = parseInt(imgObj.numLevels + sizeLevelMapping[size], 10);
    }
  
    return level;
  }


  /* Get group id from the sequence string (e.g. 1 from 1.2)*/
  function getGroupIdFromSequence(sequence) {
    var sequenceInfo = sequence.toString().split(/\./);
    return sequenceInfo[0];
  }


  /* Get stacks URL for a given index and size */
  function getImgStacksURL(index, size) {
    return (stacksURL + '/image/' + druid + '/' + imgData[index].id + '_' + size);
  }

  init();
});



