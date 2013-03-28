$.support.cors = true;

/* Function to make an array unique */
Array.prototype.unique = function() {
  var o = {}, i, l = this.length, r = [];
  for (i = 0; i < l; i = i+1) o[this[i]] = this[i];
  for (i in o) r.push(o[i]); return r;
};

/* Main purlEmbed function comprising private variables and methods */
var purlEmbed = (function(data, pid, stacksURL, config, parentSelector) {
  var imgData, currentSequence, druid;
  var groups = [];
  var constants = { 'djatokaBaseResolution': 92, 'thumbSize': 400 };
  var currentSize = 'thumb';
  var sizes = [ 'thumb', 'small', 'medium', 'large', 'xlarge', 'full' ];
  var views = [ 'zoom' ];
  var sizeLevelMapping = { 'small':  -3, 'medium': -2, 'large': -1, 'xlarge': 0,'full': 1 };
  var origContainerWidth, origContainerHeight;
  var inputSequence, inputSize, inputLayout, inputZoomIncrement;
  var isFullScreenOn = false;
  var layouts = [ 'thumbs-nav-top', 'thumbs-nav-bottom', 'thin-nav-top', 'thin-nav-bottom' ];
  var availableSizes = [];

  /* Constructor function */
  (function init() {
    var params, match;

    if (typeof data === 'undefined') return;
    if (!config) config = {};

    imgData = data;

    inputSequence = config.sequence;
    inputSize = config.size;
    inputLayout = config.layout || 'thumbs-nav-top';

    if (config.availableSizes && config.availableSizes.length > 0) {
      availableSizes = validateSizes(config.availableSizes);
    } else {
      $.merge($.merge(availableSizes, sizes), views);
    }

    changeLayout(inputLayout);

    $(window).bind('hashchange', function(){
      setURLSuffix();
    });

    if (typeof peContainerWidth === 'undefined') {
      peContainerWidth = undefined;
      origContainerWidth = $(window).width();
    } else {
      origContainerWidth = parseInt(peContainerWidth, 10);
    }

    if (typeof peContainerHeight === 'undefined') {
      peContainerHeight = undefined;
      origContainerHeight = $(window).height();
    } else {
      origContainerHeight = parseInt(peContainerHeight, 10);
    }

    if (typeof parentSelector === 'undefined') {
      $('.pe-full-screen-nav').hide();
    }

    setProperties(peContainerWidth, peContainerHeight);
    setURLSuffix();
    setFullScreenControls();

    if (typeof currentSequence === 'undefined') {
      currentSequence = imgData[0].sequence;
    }

    if ($.inArray(currentSize, availableSizes) === -1) {
      currentSize = availableSizes[0];
    }

    if (typeof inputSize === 'undefined') {
      inputSize = currentSize;
    } else {
      match = /^zoom([-+]\d+)$/.exec(inputSize);

      if (match) {
        inputSize = 'zoom';
      }

      if (match && match[1] !== 'undefined') {
        inputZoomIncrement = parseInt(match[1], 10);
      }
    }

    if (typeof inputSequence !== 'undefined') {
      currentSequence = validateSequence(inputSequence);
    }

    if (typeof inputSequence !== 'undefined' && isValidSize(inputSize)) {
      currentSize = inputSize;
    }

    loadImgsInVerticalNavigation(getArrayIndexUsingSequence(currentSequence));
  })();

  /* Calculate properties for each file and store them in JSON data object */
  function setProperties(peContainerWidth, peContainerHeight) {
    var containerWidth = $(window).width();
    var containerHeight = $(window).height();
    groups = [];

    $.each(imgData, function(index, imgObj) {
      var seq = imgObj.sequence;
      var levels = getJP2NumOfLevels(imgObj.width, imgObj.height);
      var groupId = parseInt(getGroupIdFromSequence(imgObj['sequence']), 10);

      imgData[index].numLevels = levels;
      imgData[index].aspectRatio = parseFloat(imgObj['width']/imgObj['height']).toFixed(2);
      imgData[index].groupId = groupId;

      groups.push(groupId);

      $.each(nonZoomSizes(availableSizes), function(j, size) {
        return (function(s) {
          imgData[index][s] = getDimensionsForSize(index, s);
          imgData[index]['level-for-' + s] = getLevelForSize(s, index);
        })(size);
      });
    });

    druid = pid;
    groups.unique(); // clear duplicate group ids

    if (typeof peContainerWidth !== 'undefined') {
      containerWidth = parseInt(peContainerWidth, 10);
    }

    if (typeof peContainerHeight !== 'undefined') {
      containerHeight = parseInt(peContainerHeight, 10);
    }

    $('.pe-container').width(containerWidth).height(containerHeight);
  }

  /* show image for a given sequence and size */
  function showImg(sequence, size) {
    var index = getArrayIndexUsingSequence(sequence);
    var id = imgData[index].id;
    var seqIndex = getSequenceIndex(index);
    var imgNumber;

    if (index < 0) return;

    currentSize = size;
    currentSequence = sequence;

    imgNumber = parseInt(index, 10) + 1;

    loadImage(index, size);
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

    $('#pe-zpr-frame').remove();
    $('.pe-img-canvas').remove();

    $('.pe-img-viewfinder').width(parseInt($('.pe-container').width(), 10) - 12);

    if ($('.pe-h-nav').length)  {
      $('.pe-img-viewfinder').height(parseInt($('.pe-container').height(), 10) - 126 - 10);
    } else {
      $('.pe-img-viewfinder').height(parseInt($('.pe-container').height(), 10) - 66);
    }

    $('.pe-img-viewfinder').removeClass('pe-overflow-hidden');

    if (size == "zoom") {
      loadZpr(index);

    } else {
      loadImgsInVerticalNavigation(index);

      url = getImgStacksURL(index, size);
      dimensions = getDimensionsForSize(index, size);
      imgWidth = dimensions.width;
      imgHeight = dimensions.height;

      $('<img class="pe-img-canvas">')
        .removeAttr('src').attr({ 'src': url })
        .width(imgWidth).height(imgHeight)
        .click(function() {
          if (!isFullScreenOn) {
            $('.pe-full-screen-ctrl').click();
          }
        })
        .appendTo('.pe-img-viewfinder')
        .show();
    }
  }

  /* Loads the image in ZPR UI */
  function loadZpr(index) {
    var id = imgData[index].id;
    var z;

    currentSize = 'zoom';

    $('<div id="pe-zpr-frame">')
      .html('')
      .width(parseInt($('.pe-container').width(), 10) - 20)
      .appendTo('.pe-img-viewfinder')
      .show();

    if ($('.pe-h-nav').length)  {
      $('#pe-zpr-frame').height(parseInt($('.pe-container').height(), 10) - 125 - 20);
    } else {
      $('#pe-zpr-frame').height(parseInt($('.pe-img-viewfinder').height(), 10) - 5);
    }

    $('.pe-img-viewfinder').addClass('pe-overflow-hidden');

    z = new zpr('pe-zpr-frame', {
      'imageStacksURL': stacksURL + '/image/' + druid + '/' + id,
      'width': imgData[index].width,
      'height': imgData[index].height,
      'marqueeImgSize': 40,
      'zoomIncrement': inputZoomIncrement
    });

    loadImgsInVerticalNavigation(index);
  }


  /* Load images in horizontal navigation bar */
  function loadImgsInHorizontalNavigation(index) {
    var seqIndex = getSequenceIndex(index);
    var i, index, thumbDimensions;

    if (seqIndex <= 0) {
      $('.pe-h-nav-img-01')
        .attr('src', peServerURL + '/images/img-view-first-ptr.png')
        .width(50).height(40)
        .click(function() {});
    } else {
      index = getIndexForFirstImgInSequence(seqIndex - 1);
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
        .attr('src', peServerURL + '/images/img-view-last-ptr.png')
        .width(50).height(40)
        .click(function() {});
    } else {
      index = getIndexForFirstImgInSequence(seqIndex + 1);
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

      $('.pe-h-nav-prev')
        .removeClass('pe-h-nav-prev-active')
        .unbind();

      $('.pe-h-nav-next')
        .removeClass('pe-h-nav-next-active')
        .unbind();

      $('.pe-img-hover-nav-prev').remove();
      $('.pe-img-hover-nav-next').remove();

      if ((seqIndex - 1) >= 0) {
        $('.pe-h-nav-prev')
          .click(function() { prev(seqIndex); })
          .addClass('pe-h-nav-prev-active');

        $('<div class="pe-img-hover-nav-prev"></div>')
          .hover(function() { $(this).fadeTo('fast', 0.4); })
          .mouseout(function() { $(this).fadeTo('fast', 0); })
          .click(function() { prev(seqIndex); })
          .appendTo('.pe-nav-contents');
      }

      if ((seqIndex + 1) < groups.length) {
        $('.pe-h-nav-next')
          .click(function() { next(seqIndex); })
          .addClass('pe-h-nav-next-active');

        $('<div class="pe-img-hover-nav-next"></div>')
          .hover(function() { $(this).fadeTo('fast', 0.4); })
          .mouseout(function() { $(this).fadeTo('fast', 0); })
          .click(function() { next(seqIndex); })
          .appendTo('.pe-nav-contents');
      }
    }
  }

  /* Load images in vertical navigation bar */
  function loadImgsInVerticalNavigation(index) {
    var seqIndex = getSequenceIndex(index);
    var url, height, html = "", li;
    var cselectJson = [];

    for (var i = 0; i < imgData.length; i++) {
      if (groups[seqIndex] == getGroupId(imgData[i].sequence)) {
        height = getAspectRatioBasedHeight(100, i);
        url = getImgStacksURL(i, 'thumb');

        if (index == i) {
          li = "<li class=\"pe-v-nav-selected-img\"><img src=\"" + url + "\" style=\"width: 100px; height:" + height + "px\"></li>";
        } else {
          li = "<li class=\"pe-v-nav-img\"><a href=\"javascript:loadImage('" + imgData[i].id + "', '" + currentSize + "')\"><img src=\"" + url + "\" style=\"width: 100px; height:" + height + "px\"></a></li>"
        }
      }
    }

    if ($.inArray('thumb', availableSizes) >= 0) {
      $('.pe-v-nav-selected-img').append($('<ul class=\"pe-v-nav-sizes\">'));

      html = "<span class=\"pe-thumb-img-viewer\" href=\"javascript:;\">thumb</span>" +
          "<span class=\"pe-v-nav-img-size\"> (" +  getDimensionsForSizeWxH(index, 'thumb') + ")</span>";

      $(".pe-v-nav-sizes").append("<li>" + html + "</li>");
      cselectJson.push({ 'html': html, 'size': 'thumb', 'index': index });
    }

    if (imgData[index].rightsWorld === "true") {
      if (imgData[index].rightsStanford === "false" && imgData[index].rightsWorldRule === "") {
        $.each(nonZoomSizes(availableSizes), function(i, size) {
          html = "";
          html = "<span class=\"pe-" + size + "-img-viewer\" href=\"javascript:;\">" + size + "</span>" +
              "<span class=\"pe-v-nav-img-size\"> ("  + getDimensionsForSizeWxH(index, size) + ")</span>" +
              "<a href=\"" + getDownloadLink(index, size) + "\" class=\"pe-" + size + "-img-viewer-download pe-download-icon\"></a>";

          if (size !== "thumb") {
            $(".pe-v-nav-sizes").append("<li>" + html + "</li>");
            cselectJson.push({ 'html': html, 'size': size, 'index': index });
          }
        });
      }
    }

    if (imgData[index].rightsStanford === "true") {
      if (imgData[index].rightsStanfordRule !== "no-download") {
        $.each(nonZoomSizes(availableSizes), function(i, size) {
          var url = "https://" + $(location).attr('host') + '/auth' +
            $(location).attr('pathname').replace(/^\/auth/, '') +
            $(location).attr('hash').replace(/thumb|small|medium|large|xlarge|full|zoom/, size);

          html = "";
          html = "<span class=\"pe-" + size + "-img-viewer\" href=\"" + url + "\" class=\"su\">" + size + "</span>" +
              "<span class=\"pe-v-nav-img-size\"> (" + getDimensionsForSizeWxH(index, size)  + ")</span>" +
              "<a href=\"" + getDownloadLink(index, size) + "\" class=\"pe-" + size + "-img-viewer-download pe-download-icon\"></a>" +
              "<img src=\"" + peServerURL + "/images/icon-stanford-only.png\" class=\"pe-icon-stanford-only\" alt=\"Stanford Only\" title=\"Stanford Only\"/>";

          if (size !== "thumb") {
            $(".pe-v-nav-sizes").append("<li>" + html + "</li>");
            cselectJson.push({ 'html': html, 'size': size, 'index': index });
          }
        });
      }
    }


    if ($.inArray('zoom', availableSizes) >= 0) {
      if (imgData[index].rightsWorld === "true") {
        li = "<span class=\"pe-zoom-img-viewer\" href=\"javascript:;\" title=\"Zoom View\">zoom</span>";
      } else if (imgData[index].rightsStanford === "true") {
        var url = "https://" + $(location).attr('host') + '/auth' + $(location).attr('pathname').replace(/^\/auth/, '') +
          $(location).attr('hash').replace(/thumb|small|medium|large|xlarge|full|zoom/, 'zoom');

        li = "<span class=\"pe-zoom-img-viewer su\" href=\"" + url + "\" title=\"Zoom View\">zoom</span>" +
          "<img src=\"" + peServerURL + "/images/icon-stanford-only.png\" class=\"pe-icon-stanford-only\" alt=\"Stanford Only\" title=\"Stanford Only\"/>";
      }

      $(".pe-v-nav-sizes").append("<li><div class=\"pe-v-nav-sizes-links\">" + li + "</div></li></ul>");
      cselectJson.push({ 'html': li, 'size': 'zoom', 'index': index  });
    }

    updateViewerSizesLinks(index);
    renderCselect(cselectJson);
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
  }


  function getDownloadLink(index, size) {
    var href = stacksURL + '/image/' + druid + '/' + imgData[index].id + '_' + size + '?action=download';
    return href;
  }


  function renderCselect(cselectJson) {
    var reverseMenuDirection = false;

    if (inputLayout === 'thumbs-nav-bottom' || inputLayout === 'thin-nav-bottom' ) {
      reverseMenuDirection = true;
    }

    $('.pe-dd-cselect').cselect({
      data: cselectJson,
      width: 220,
      defaultSelectedIndex: getIndexForSize(currentSize, cselectJson),
      reverseMenuDirection: reverseMenuDirection,
      onSelected: function(data) {
        showImg(currentSequence, data.selectedData.size);
      }
    });
  }

  /* Parse URL hash params */
  function setURLSuffix() {
    var params = parseHashParams();

    currentSequence = params[0];
    currentSize = params[1];
  }

  /* Parse URL hash params */
  function parseHashParams() {
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
    }

    return [sequence, size];
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

  /* Get index for a given size (default is 0) */
  function getIndexForSize(size, cselectJson) {
    var index = 0;

    for (var i = 0; i < cselectJson.length; i++) {
      if (size === (cselectJson[i]).size) {
        index = i;
      }
    }

    return index;
  }

  /* Validate input sequence */
  function validateSequence(inputSeq) {
    var flag = false;

    for (var i = 0; i < imgData.length; i++) {
      if (imgData[i].sequence === inputSeq) {
        flag = true;
      }
    }

    return flag ? inputSeq : imgData[0].sequence;
  }

  /* Set full screen toggle options */
  function setFullScreenControls() {
    $('.pe-full-screen-ctrl').click(function() {
      if (!isFullScreenOn) {
        $(parentSelector + " > .pe-container")
          .addClass('pe-container-full-screen');

        $('.pe-full-screen-ctrl').hide();
        $('.pe-full-screen-close').show();
        setProperties($(window).width() - 40, $(window).height() - 40);

        showImg(currentSequence, currentSize);
        isFullScreenOn = !isFullScreenOn;
      }
    });

    $('.pe-full-screen-close').click(function() {
      if (isFullScreenOn) {
        $(parentSelector + " > .pe-container")
          .removeClass('pe-container-full-screen');

        $('.pe-full-screen-ctrl').show();
        $('.pe-full-screen-close').hide();
        setProperties(origContainerWidth, origContainerHeight);
      }

      showImg(currentSequence, currentSize);
      isFullScreenOn = !isFullScreenOn;
    });

    $(document).keyup(function(e) {
      // escape key code is 27
      if (e.keyCode == 27 && isFullScreenOn) {
        $('.pe-full-screen-close').click();
      }

      // 'f' key code is 70
      if (e.keyCode == 70) {
        isFullScreenOn ?
          $('.pe-full-screen-close').click() :
          $('.pe-full-screen-ctrl').click();
      }

    });
  }

  /* Show selected layout and hide/remove other layouts */
  function changeLayout(currentLayout) {
    $.each(layouts, function(i, layout) {
      if (layout === currentLayout) {
        $('.pe-img-viewer-' + layout).show();
      } else {
        $('.pe-img-viewer-' + layout).remove();
      }
    });
  }

  /* Check if a given size value is valid */
  function isValidSize(size) {
    var valid = false;

    $.each([sizes, views], function() {
      $.each(this, function(i, availableSize) {
        var regex = new RegExp('^' + availableSize + '$', 'i');
        if (regex.test(size)) {
          valid = true;
        }
      });
    });

    return valid;
  }

  /* validate array of sizes */
  function validateSizes(list) {
    var validSizes = [];

    $.each(list, function(i, size) {
      if (isValidSize(size)) {
        validSizes.push(size.toLowerCase());
      }
    });

    return validSizes;
  }

  function nonZoomSizes(list) {
    var nonZoomSizes = [];

    $.each(list, function(i, size) {
      if (size !== 'zoom') {
        nonZoomSizes.push(size);
      }
    });

    return nonZoomSizes;
  }

});



