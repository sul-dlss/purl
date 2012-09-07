/* Function to make an array unique */
Array.prototype.unique = function() { 
  var o = {}, i, l = this.length, r = [];    
  for (i = 0; i < l; i = i+1) o[this[i]] = this[i];    
  for (i in o) r.push(o[i]); return r;
};

$(function() {
  var pe = new purlEmbed(imgInfo);
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

      $(window).bind('hashchange', function(){
        setURLSuffix();
      });

      setProperties();        
      setURLSuffix();
      
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

    $('.pe-container')
      .width($(window).width() - 20)
      .height($(window).height() - 20);
  }

  /* show image for a given sequence and size */
  function showImg(sequence, size) {
    var index = getArrayIndexUsingSequence(sequence);
    var id = imgData[index].id;
    var seqIndex = getSequenceIndex(index);
    var imgNumber;

    if (index < 0) return;
    
    currentSize = size;
    imgNumber = parseInt(index, 10) + 1;

    if (size === 'zoom') {
      loadZpr(index);
    } else {
      loadImage(index, size);      
    }

    loadImgsInHorizontalNavigation(index);
    loadImgsInVerticalNavigation(index); 

    $('.pe-h-nav-pagination').html((getSequenceIndex(index) + 1) + ' of ' + groups.length);

    setHorizontalNavigationLinks(seqIndex);
  }

  /* Loads the image for a given size */
  function loadImage(index, size) {
    var id = imgData[index].id;
    var url, dimensions;
    var imgWidth, imgHeight;

    if (typeof size === "undefined") {
      size = currentSize;
    } else {
      currentSize = size;  
    } 

    $(location).attr('href', '#image/' + imgData[index]['sequence'] + '/' + size);

    if (size == "zoom") {
      loadZpr(index);
      return;
    }

    loadImgsInVerticalNavigation(index); 

    url = getImgStacksURL(index, size);
    dimensions = getDimensionsForSize(index, size);
    imgWidth = dimensions.width;
    imgHeight = dimensions.height;

    $('#pe-zpr-frame').hide();

    $('.pe-img-viewfinder')    
      .width(parseInt($('.pe-container').width(), 10) - parseInt($('.pe-v-nav').width(), 10) - 10);

    if ($('.pe-h-nav').length)  {
      $('.pe-img-viewfinder').height(parseInt($('.pe-container').height(), 10) - 85 - 10);
    } else {
      $('.pe-img-viewfinder').height(parseInt($('.pe-container').height(), 10) - 10);
    }

    $('.pe-img-canvas')      
      .removeAttr('src').attr({ 'src': url })
      .width(imgWidth).height(imgHeight)
      .show();
  }

  /* Loads the image in ZPR UI */
  function loadZpr(index) {
    var id = imgData[index].id;
    var z;

    currentSize = 'zoom';
    $(location).attr('href', '#image/' + imgData[index]['sequence'] + '/zoom');

    $('.pe-img-canvas').hide();

    $('#pe-zpr-frame')
      .html('')
      .height(parseInt($('.pe-container').height(), 10) - 85 - 20)
      .width(parseInt($('.pe-container').width(), 10) - parseInt($('.pe-v-nav').width(), 10) - 20)
      .show();
    
    z = new zpr('pe-zpr-frame', { 
      'imageStacksURL': stacksURL + '/image/' + druid + '/' + id, 
      'width': imgData[index].width, 
      'height': imgData[index].height, 
      'marqueeImgSize': 40  
    });  
    
    loadImgsInVerticalNavigation(index); 
  }


  /* Load images in horizontal navigation bar */
  function loadImgsInHorizontalNavigation(index) {
    var seqIndex = getSequenceIndex(index);
    var i, index, thumbDimensions;
    
    if (seqIndex <= 0) { 
      $('.pe-h-nav-img-01')
        .attr('src', '/images/img-view-first-ptr.png')
        .width(65).height(40)
        .click(function() {});    
    } else {
      index = getIndexForFirstImgInSequence(seqIndex-1);
      thumbDimensions = getDimensionsToFitBox(65, 40, index);
      
      $('.pe-h-nav-img-01')
        .attr('src', getImgStacksURL(index, 'thumb'))
        .addClass('pe-cursor-pointer')
        .width(thumbDimensions[0]).height(thumbDimensions[1])
        .click(function() { prev(seqIndex); });
    }

    index = getIndexForFirstImgInSequence(seqIndex);
    thumbDimensions = getDimensionsToFitBox(65, 40, index);

    $('.pe-h-nav-img-02')
      .attr('src', getImgStacksURL(index, 'thumb'))
      .width(thumbDimensions[0]).height(thumbDimensions[1]);
    
    if ((seqIndex + 1) == groups.length) {
      $('.pe-h-nav-img-03')
        .attr('src', '/images/img-view-last-ptr.png')    
        .width(65).height(40)
        .click(function() {});    
    } else {
      index = getIndexForFirstImgInSequence(seqIndex+1);
      thumbDimensions = getDimensionsToFitBox(65, 40, index);  

      $('.pe-h-nav-img-03')
        .attr('src', getImgStacksURL(index, 'thumb'))
        .addClass('pe-cursor-pointer')      
        .width(thumbDimensions[0]).height(thumbDimensions[1])
        .click(function() { next(seqIndex); });
    }    
  }

  /* Enable/disable navigation links for horizontal navigation */
  function setHorizontalNavigationLinks(seqIndex) {    
    if ($('.pe-h-nav-prev').length != 0 && $('.pe-h-nav-next').length != 0) {        

      $('.pe-h-nav-prev > img').attr('src', '/images/img-view-group-prev-inactive.png');
      $('.pe-h-nav-next > img').attr('src', '/images/img-view-group-next-inactive.png');      
      $('.pe-h-nav-prev').unbind().css('cursor', 'default');      
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
    var seqIndex = getSequenceIndex(index);  
    var url, height, html = "", li;          

    $('.pe-v-nav').html("");
    
    for (var i = 0; i < imgData.length; i++) {
      if (groups[seqIndex] == getGroupId(imgData[i].sequence)) {
        height = getAspectRatioBasedHeight(100, i);
        url = getImgStacksURL(i, 'thumb');

        if (index == i) {
          li = "<li class=\"pe-v-nav-selected-img\"><img src=\"" +  url  + "\" style=\"width: 100px; height:" + height + "px\"></li>";
        } else {
          li = "<li class=\"pe-v-nav-img\"><a href=\"javascript:loadImage('" + imgData[i].id + "')\"><img src=\"" + url + "\"></a></li>"
        }

        $('.pe-v-nav').append(li);
      }  
    }
    
    $('.pe-v-nav-selected-img').append($('<ul class=\"pe-v-nav-sizes\">'));
    
    html = "<div class=\"pe-v-nav-sizes-links\">" + 
        "<a class=\"pe-thumb-img-viewer\" href=\"javascript:;\">" + 
        "<span class=\"pe-obscure\">View the</span> thumb <span class=\"pe-obscure\"> size of image </span>" + 
        "<span class=\"pe-obscure\" id=\"pe-thumb-img-viewer-id\"></span></a>" +  
        "<span class=\"pe-thumb-size-img-viewer pe-v-nav-img-size\"></span>" + 
      "</div>" + 
      "<div class=\"pe-v-nav-sizes-download\"> " + 
        "<a class=\"pe-thumb-img-viewer-download\">" + 
          "<span class=\"pe-obscure\">Download the thumb size of image </span>" + 
          "<span class=\"pe-obscure pe-thumb-img-viewer-download-id\"></span>" + 
          "<img src=\"/images/icon-download.png\" alt=\"\" title=\"\"/>" + 
        "</a>" + 
      "</div>";    
    $(".pe-v-nav-sizes").append("<li>" + html + "</li>");

    if (imgData[index].rightsWorld === "true") {
      if (imgData[index].rightsStanford === "false" && imgData[index].rightsWorldRule === "") {
        $.each(sizes, function(i, size) { 
          html = "";
          html = "<div class=\"pe-v-nav-sizes-links\">" + 
              "<a class=\"pe-" + size + "-img-viewer\" href=\"javascript:;\">" + 
              "<span class=\"pe-obscure\">View the</span> " + size + " <span class=\"pe-obscure\"> size of image </span>" + 
              "<span class=\"pe-obscure pe-" + size + "-img-viewer-id\"></span></a>" +  
              "<span class=\"pe-" + size + "-size-img-viewer pe-v-nav-img-size\"></span>" + 
            "</div>" + 
            "<div class=\"pe-v-nav-sizes-download\"> " + 
              "<a class=\"pe-" + size + "-img-viewer-download\">" + 
                "<span class=\"pe-obscure\">Download the " + size + " size of image </span>" + 
                "<span class=\"pe-obscure pe-" + size +  "-img-viewer-download-id\"></span>" + 
                "<img src=\"/images/icon-download.png\" alt=\"\" title=\"\"/>" + 
              "</a>" + 
            "</div>";    

          if (size !== "thumb") { 
            $(".pe-v-nav-sizes").append("<li>" + html + "</li>");      
          }
        });
      }  
    }
      
    if (imgData[index].rightsStanford === "true") {
      if (imgData[index].rightsStanfordRule !== "no-download") { 
        $.each(sizes, function(i, size) { 
          var url = "https://" + $(location).attr('host') + '/auth' +       
            $(location).attr('pathname').replace(/^\/auth/, '') + 
            $(location).attr('hash').replace(/thumb|small|medium|large|xlarge|full|zoom/, size);
          
          html = "";    
          html = "<div class=\"pe-v-nav-sizes-links\">" + 
              "<a class=\"pe-" + size + "-img-viewer\" href=\"" + url + "\" class=\"su\">" + 
              "<span class=\"pe-obscure\">View the</span> " + size + " <span class=\"pe-obscure\"> size of image </span>" + 
              "<span class=\"pe-obscure pe-" + size + "-img-viewer-id\"></span></a>" +  
              "<span class=\"pe-" + size + "-size-img-viewer pe-v-nav-img-size\"></span>" + 
            "</div>" + 
            "<div class=\"pe-v-nav-sizes-download\"> " + 
              "<a class=\"pe-" + size + "-img-viewer-download\">" + 
                "<span class=\"pe-obscure\">Download the " + size + " size of image </span>" + 
                "<span class=\"pe-obscure pe-" + size +  "-img-viewer-download-id\"></span>" + 
                "<img src=\"/images/icon-download.png\" alt=\"\" title=\"\"/>" + 
              "</a>" + 
              "<img src=\"/images/icon-stanford-only.png\" class=\"pe-icon-stanford-only\" alt=\"Stanford Only\" title=\"Stanford Only\"/>" + 
            "</div>";    

          if (size !== "thumb") {   
            $(".pe-v-nav-sizes").append("<li>" + html + "</li>");      
          }  
        });        
      }
    }  
      
    if (imgData[index].rightsWorld === "true") {
      li = "<a class=\"pe-zoom-img-viewer\" href=\"javascript:;\" title=\"Zoom View\">zoom<span class=\"pe-obscure\"> of image 1</span></a>";
    } else if (imgData[index].rightsStanford === "true") {
      var url = "https://" + $(location).attr('host') + '/auth' + $(location).attr('pathname').replace(/^\/auth/, '') + 
        $(location).attr('hash').replace(/thumb|small|medium|large|xlarge|full|zoom/, 'zoom');    

      li = "<a class=\"pe-zoom-img-viewer su\" href=\"" + url + "\" title=\"Zoom View\">zoom<span class=\"pe-obscure\"> of image 1</span></a>" + 
        "<img src=\"/images/icon-stanford-only.png\" class=\"pe-icon-stanford-only\" alt=\"Stanford Only\" title=\"Stanford Only\"/>";
    }    

    $(".pe-v-nav-sizes").append("<li><div class=\"pe-v-nav-sizes-links\">" + li + "</div></li></ul>");                  
    
    updateViewerSizesLinks(index);  
  }

  /* Update link attributes in the image viewer pane */
  function updateViewerSizesLinks(index) {
    var imgNumber = parseInt(index, 10) + 1;

    $('.pe-thumb-img-viewer').click(function() { loadImage(index, 'thumb'); });
    $('.pe-zoom-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadZpr(index); }});

    $('.pe-small-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(index, 'small'); }});
    $('.pe-medium-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(index, 'medium'); }});
    $('.pe-large-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(index, 'large'); }});
    $('.pe-xlarge-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(index, 'xlarge'); }});
    $('.pe-full-img-viewer').click(function() { if (!$(this).hasClass('su')) { loadImage(index, 'full'); }});

    $.each(sizes, function(i, size) {
      $('.pe-' + size + '-img-viewer-id').html(imgNumber);
      $('.pe-' + size + '-img-viewer-download-id').html(imgNumber);

      $('.pe-' + size + '-img-viewer-download').attr({
        'href': stacksURL + '/image/' + druid + '/' + imgData[index].id + '_' + size + '.jpg?action=download',
        'title': 'Download ' + imgData[index].id + '_' + size + '.jpg'
      });

      $('.pe-' + size + '-size-img-viewer').html('(' + getDimensionsForSizeWxH(index, size) + ')' );        
    });
  }


  /* Parse URL hash params */
  function setURLSuffix() {
    var href = $(location).attr('href');
    var match; 
    var pageNo = 1;
    var sequence = 1; 
    var size = currentSize;
    var flag = false;

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

  /* Get dimensions for a given size (thumb, small etc.) in 'width x height' format */
  function getDimensionsForSizeWxH(imgIndex, size) {
    var dimensions = getDimensionsForSize(imgIndex, size);
    return (dimensions.width + ' x ' + dimensions.height);
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

  /* Display prev image from the group */
  function prev(seqIndex) {
    var index = getIndexForFirstImgInSequence(seqIndex - 1);
    var sequence = imgData[index].sequence;

    showImg(sequence, currentSize);
  }

  /* Display next image from the group */
  function next(seqIndex) {
    var index = getIndexForFirstImgInSequence(seqIndex + 1);
    var sequence = imgData[index].sequence;

    showImg(sequence, currentSize);
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
    for (var i = 0; i < imgData.length; i++) {
      var sequence = imgData[i].sequence;
    
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



