function zpr(viewFinderId, inputValues) {
  
  var viewFinder = $('#' + viewFinderId); // viewFinder DOM element
  var imgFrame   = undefined; // for imgFrame DOM element
  var imgFrameId = viewFinderId + "-img-frame";
  
  var settings = {
    tileSize: 512,            // dimension for a square tile 
    marqueeImgSize: 125,      // max marquee dimension (should be > 50)
    preloadTilesOffset: 0,    // rows/columns of tiles to preload
    djatokaBaseResolution: 92 // djatoka JP2 base resolution for levels
  };  
  
  var errors = [];    
  var currentLevel = 1;
  var currentRotation = 0;
  
  var jp2 = { width: 0, height: 0, levels: undefined, imgURL: undefined }   
  var imgFrameAttrs = { relativeLoc: {}, proportionalWidth: 0, proportionalHeight: 0 };
  var marqueeAttrs = { imgWidth: 0, imgHeight: 0, width: 0, height: 0 }; 

  /* init() function */
  function init() {
    // validate and store input values
    storeInputValues(inputValues);
    
    // if there are input value errors, display them and quit
    if (errors.length > 0) {
      renderErrors();
      return;
    }
        
    // create and attach 'imgFrame' element to 'viewFinder'
    viewFinder
      .addClass('zpr-view-finder')
      .append($('<div>', { 'id': imgFrameId, 'class': 'zpr-img-frame' }));        
      
    imgFrame = $('#' + imgFrameId);    
    currentLevel = getLevelForContainer(viewFinder.width(), viewFinder.height());
    
    setImgFrameSize(currentLevel);            
    setupImgFrameDragging();
    storeRelativeLocation();
    addControlElements();
  }


  /* validate mandatory and optional input values, and store them locally */
  function storeInputValues(inputValues) {                
    // store jp2 width from input values
    if (util.isValidLength(inputValues.width)) {
      jp2.width = parseInt(inputValues.width, 10);
    } else {
      errors.push('Error: Input width is empty or not valid');
    }
    
    // store jp2 height from input values
    if (util.isValidLength(inputValues.height)) {
      jp2.height = parseInt(inputValues.height, 10);
    } else {
      errors.push('Error: Input height is empty or not valid')
    }

    // store image stacks URL from input values
    if (util.isValid(inputValues.imageStacksURL)) {
      jp2.imgURL = inputValues.imageStacksURL.toString();
    } else {
      errors.push('Error: Input Image Stacks URL is empty or not valid');
    }    
    
    // store jp2 levels from input values (optional argument)
    if (util.isValidLength(inputValues.levels)) {
      jp2.levels = parseInt(inputValues.levels, 10);
    } else {
      jp2.levels = getNumLevels();
    }

    // store marquee size from input values (optional argument)
    if (util.isValidLength(inputValues.marqueeImgSize)) {
      settings.marqueeImgSize = parseInt(inputValues.marqueeImgSize, 10);
    }
  }
  
  /* render input errors to page */
  function renderErrors() {
    var errorBlock = $('<div></div>').addClass('zpr-error');
    
    $.each(errors, function(index, error) {
      errorBlock
        .append(error + '</br>');
    });
    
    if (errors.length > 0) {
      viewFinder.append(errorBlock);
    }    
  }
  
  
  /* add zoom and other controls */
  function addControlElements() {    
    // add zoom/rotate controls
    viewFinder
    .append($('<div>').attr({ 'class': 'zpr-controls' })
      .append($('<img>')
        .attr({ 'id': viewFinderId + '-zoom-in', 'src': purlServerURL + '/images/zpr-zoom-in.png' })
        .click(function() { zoom('in'); }))
      .append($('<img>')
        .attr({ 'id': viewFinderId + '-zoom-out', 'src': purlServerURL + '/images/zpr-zoom-out.png' })
        .click(function() { zoom('out'); }))
      .append($('<img>')
        .attr({ 'id': viewFinderId + '-rotate-cw', 'src': purlServerURL + '/images/zpr-rotate-cw.png' })
        .click(function() { rotate('cw'); }))
      .append($('<img>')
        .attr({ 'id': viewFinderId + '-rotate-ccw', 'src': purlServerURL + '/images/zpr-rotate-ccw.png' })
        .click(function() { rotate('ccw'); }))
    );
    
    setupMarquee();
  }  
    
  
  /* get total levels for the jp2 */
  function getNumLevels() {
    var longestSide = Math.max(jp2.width, jp2.height);
    var level = 0;
    
    while (longestSide > settings.djatokaBaseResolution) {
      longestSide = Math.round(longestSide / 2);
      level += 1;
    }
        
    return level;
  }

  
  /* set imgFrame dimensions */
  function setImgFrameSize(level) {    
    imgFrame.width(getImgDimensionsForLevel(level)[0]);    
    imgFrame.height(getImgDimensionsForLevel(level)[1]);

    imgFrameAttrs.proportionalWidth  = Math.round(jp2.width / Math.pow(2, jp2.levels - currentLevel));
    imgFrameAttrs.proportionalHeight = Math.round(jp2.height / Math.pow(2, jp2.levels - currentLevel));
    
    setMarqueeDimensions();    
    positionImgFrame();   
  }

  
  /* get dimensions for a given level */
  function getImgDimensionsForLevel(level) {
    var divisor = Math.pow(2, (jp2.levels - level));
    var height  = Math.round(jp2.height / divisor);    
    var width   = Math.round(jp2.width / divisor);
    
    return ([width, height]);    
  }
  
  
  /* calculate level for a given container */
  function getLevelForContainer(ctWidth, ctHeight) {
    var jp2Width  = jp2.width;
    var jp2Height = jp2.height;
    var level = jp2.levels;
    
    if (!util.isValidLength(ctHeight)) {
      ctHeight = ctWidth;
    }
        
    while (level >= 0) {
      if (ctWidth >= jp2Width && ctHeight >= jp2Height) {
        return util.clampLevel(level);        
      }
      
      jp2Width  = Math.round(jp2Width / 2);
      jp2Height = Math.round(jp2Height / 2);
      level -= 1;      
    }  
      
    return 0;
  }
  
  
  /* position imgFrame */
  function positionImgFrame() {
    var left = 0;
    var top = 10;
    
    if (imgFrame.width() < viewFinder.width()) {     
      left = Math.floor((viewFinder.width() / 2) - (imgFrame.width() / 2));
      
      if (imgFrame.height() < viewFinder.height()) {
        top = Math.floor((viewFinder.height() / 2) - (imgFrame.height() / 2));
      }
    } 

    // if relative location is defined, use it to position imgFrame
    if (typeof imgFrameAttrs.relativeLoc.x !== 'undefined' && 
        typeof imgFrameAttrs.relativeLoc.y !== 'undefined') {
    
       left = Math.round(viewFinder.width() / 2) - Math.ceil(imgFrameAttrs.relativeLoc.x * imgFrame.width());        
       top = Math.round(viewFinder.height() / 2) - Math.ceil(imgFrameAttrs.relativeLoc.y * imgFrame.height());        
    }    

    imgFrame.css({ 'top': top + 'px', 'left': left + 'px' });
    showTiles(); 
  }
  
  
  /* get list of visible tiles */
  function getVisibleTiles() {
    var visibleImgSpace = { left: 0, top: 0, right: 0, bottom: 0 };
    var visibleTileIds  = { leftmost: 0, topmost: 0, rightmost: 0, bottommost: 0 };
    var numVisibleTiles = { x: 0, y: 0 };
    var totalTiles      = { x: 0, y: 0 };

    var visibleTileArray = [];
    var ctr = 0;
    var tileSize = settings.tileSize;
    
    // total available tiles for imgFrame 
    totalTiles.x = Math.ceil(imgFrame.width() / tileSize);
    totalTiles.y = Math.ceil(imgFrame.height() / tileSize);
    
    // calculate visibleImgSpace location
    if (imgFrame.position().left > 0) {
      visibleImgSpace.left = imgFrame.position().left;
    }
        
    if (imgFrame.position().top > 0) {
      visibleImgSpace.top = imgFrame.position().top;
    }
    
    visibleImgSpace.right  = Math.min(imgFrame.position().left + imgFrame.width(), viewFinder.width());
    visibleImgSpace.bottom = Math.min(imgFrame.position().left + imgFrame.height(), viewFinder.height());
    
    // total tiles visible in viewFinder
    numVisibleTiles.x = Math.ceil((visibleImgSpace.right - visibleImgSpace.left) / tileSize) + 1;
    numVisibleTiles.y = Math.ceil((visibleImgSpace.bottom - visibleImgSpace.top) / tileSize) + 1;
        
    if (imgFrame.position().left < 0) {
      visibleTileIds.leftmost = Math.abs(Math.ceil(imgFrame.position().left / tileSize));
    }

    if (imgFrame.position().top < 0) {
      visibleTileIds.topmost = Math.abs(Math.ceil(imgFrame.position().top / tileSize));
    }
    
    visibleTileIds.rightmost  = visibleTileIds.leftmost + numVisibleTiles.x;
    visibleTileIds.bottommost = visibleTileIds.topmost + numVisibleTiles.y;
    
    // preload/cache extra tiles for better user experience
    visibleTileIds.leftmost   -= settings.preloadTilesOffset;
    visibleTileIds.topmost    -= settings.preloadTilesOffset;
    visibleTileIds.rightmost  += settings.preloadTilesOffset;
    visibleTileIds.bottommost += settings.preloadTilesOffset;
    
    // validate visible tile ids
    visibleTileIds.leftmost   = Math.max(visibleTileIds.leftmost, 0);
    visibleTileIds.topmost    = Math.max(visibleTileIds.topmost, 0);    
    visibleTileIds.rightmost  = Math.min(visibleTileIds.rightmost, totalTiles.x);
    visibleTileIds.bottommost = Math.min(visibleTileIds.bottommost, totalTiles.y);
    
    for (var x = visibleTileIds.leftmost; x < visibleTileIds.rightmost; x += 1) {          
      for (var y = visibleTileIds.topmost; y < visibleTileIds.bottommost; y += 1) {
        visibleTileArray[ctr] = [x, y];
        ctr += 1;
      }
    }
        
    return visibleTileArray;
  }
  
  
  /* add tiles to the imgFrame */
  function showTiles() {
    var visibleTiles = getVisibleTiles();
    var visibleTilesMap = [];
    var multiplier = Math.pow(2, jp2.levels - currentLevel);
    var tileSize = settings.tileSize;
    
    // prepare each tile and add it to imgFrame
    for (var i = 0; i < visibleTiles.length; i += 1) {
      var attrs = { x: visibleTiles[i][0], y: visibleTiles[i][1] };      
      var xTileSize, yTileSize;
      var angle = parseInt(currentRotation, 10);
      var tile = undefined;
      
      var insetValueX = attrs.x * tileSize;
      var insetValueY = attrs.y * tileSize;        
      
      attrs.id = 'tile-x' + attrs.x + 'y' + attrs.y + 'z' + currentLevel + 'r' + currentRotation + '-' + viewFinderId;      
      attrs.src = 
        jp2.imgURL + '.jpg?zoom=' + util.getZoomFromLevel(currentLevel) + 
        '&region=' + insetValueX + ',' + insetValueY + ',' + tileSize + ',' + tileSize + '&rotate=' + currentRotation;
      
      visibleTilesMap[attrs.id] = true; // useful for removing unused tiles       
      tile = $('#' + attrs.id);
                        
      if (tile.length == 0) {
        tile = $(document.createElement('img'))        
               .css({ 'position': 'absolute' })
               .attr({ 'id': attrs.id, 'src': attrs.src });
    
        distanceX = (attrs.x * tileSize) + 'px';
        distanceY = (attrs.y * tileSize) + 'px';     
        
        if (angle === 90) {
          tile.css({ 'right': distanceY, 'top': distanceX });
        } else if (angle === 180) {
          tile.css({ 'right': distanceX, 'bottom': distanceY });
        } else if (angle === 270) {
          tile.css({ 'left': distanceY, 'bottom': distanceX });
        } else {
          tile.css({ 'left': distanceX, 'top': distanceY });
        }
        
        imgFrame.append(tile);
      }      
    }
    
    removeUnusedTiles(visibleTilesMap);
    storeRelativeLocation();
    drawMarquee();    
  }
  
  
  /* remove unused tiles to save memory */
  function removeUnusedTiles(visibleTilesMap) {    
    imgFrame.find('img').each(function(index) {
      if (/^tile-x/.test(this.id) && !visibleTilesMap[this.id]) {
        $('#' + this.id).remove();       
        //console.log('removing ' + this.id); 
      }       
    });    
  }
  
  
  /* setup zoom controls */
  function zoom(direction) {
    var newLevel = currentLevel;

    if (direction === 'in') {
      newLevel = util.clampLevel(newLevel + 1); 
    } else if (direction === 'out') {
      newLevel = util.clampLevel(newLevel - 1); 
    }

    if (newLevel !== currentLevel) {
      currentLevel = newLevel;
      setImgFrameSize(currentLevel);
    }
  }
  

  /* setup rotate controls */
  function rotate(direction) {
    var newRotation = currentRotation;
    var angle = 90;

    if (direction === 'cw') {
      newRotation = currentRotation + 90;         
    } else if (direction === 'ccw') {
      newRotation = currentRotation - 90;
      angle = -90;      
    }
    
    if (newRotation < 0) { newRotation += 360; }
    if (newRotation >= 360) { newRotation -= 360; }
    
    if (newRotation !== currentRotation) {
      currentRotation = newRotation;
      swapJp2Dimensions();
      swapRelativeLocationValues(angle);
      setImgFrameSize(currentLevel);
      setupMarquee();
    }
  }


  /* for rotate actions, swap jp2 dimensions */
  function swapJp2Dimensions() {
    var tmpWidth = jp2.width;
    
    jp2.width = jp2.height;
    jp2.height = tmpWidth; 
  }


  /* for rotate actions, swap relative location values based on given value */ 
  function swapRelativeLocationValues(angle) {
    var tmpX = imgFrameAttrs.relativeLoc.x;
    
    if (parseInt(angle, 10) > 0) {
      imgFrameAttrs.relativeLoc.x = 1 - imgFrameAttrs.relativeLoc.y;
      imgFrameAttrs.relativeLoc.y = tmpX;
    } else {
      imgFrameAttrs.relativeLoc.x = imgFrameAttrs.relativeLoc.y;
      imgFrameAttrs.relativeLoc.y = 1 - tmpX;      
    }
  }

  
  /* store imgFrame relative location - for positioning after zoom/rotate */
  function storeRelativeLocation() {
    
    imgFrameAttrs.relativeLoc.x = 
      (Math.round((viewFinder.width() / 2) - imgFrame.position().left) / imgFrame.width()).toFixed(2);
            
    imgFrameAttrs.relativeLoc.y = 
      (Math.round((viewFinder.height() / 2) - imgFrame.position().top) / imgFrame.height()).toFixed(2);    
    //console.log('relative loc: ' + imgFrameAttrs.relativeLoc.x + ',' + imgFrameAttrs.relativeLoc.y);
  }
  
  
  /* setup mouse events for imgFrame dragging */
  function setupImgFrameDragging() {    
    var attrs = {
      isDragged: false, 
      left: 0,
      top: 0,
      drag: { left: 0, top: 0 },
      start: { left: 0, top: 0 },
    };
 
    imgFrame.bind({
      mousedown: function(event) {        
        if (!event) { event = window.event; } // required for IE
        
        attrs.drag.left = event.clientX;
        attrs.drag.top  = event.clientY;
        attrs.start.left = imgFrame.position().left;
        attrs.start.top  = imgFrame.position().top;
        attrs.isDragged  = true;         

        imgFrame.css({ 'cursor': 'default', 'cursor': '-moz-grabbing', 'cursor': '-webkit-grabbing' });
           
        return false;
      },
      
      mousemove: function(event) {
        if (!event) { event = window.event; } // required for IE
        
        if (attrs.isDragged) {
          attrs.left = attrs.start.left + (event.clientX - attrs.drag.left);      
          attrs.top = attrs.start.top + (event.clientY - attrs.drag.top);
  
          imgFrame.css({
            'left': attrs.left + 'px',
            'top': attrs.top + 'px'
          });
                    
          showTiles();        
        }        
      }      
    });

    imgFrame.ondragstart = function() { return false; } // for IE    
    $(document).mouseup(function() { stopImgFrameMove();  });

    function stopImgFrameMove() {
      attrs.isDragged = false;      
      imgFrame.css({ 'cursor': '' });
    }        
  }
  
  
  /* setup mouse events for marquee dragging */
  function setupMarqueeDragging() {
    var marqueeBgId = viewFinderId + '-marquee-bg';    
    var marqueeId = viewFinderId + '-marquee';        
    
    var attrs = {
      isDragged: false, 
      left: 0,
      top: 0,
      drag: { left: 0, top: 0 },
      start: { left: 0, top: 0 },
    };
 
    var marquee = $('#' + marqueeId);   
 
    marquee.bind({
      mousedown: function(event) {        
        if (!event) { event = window.event; } // required for IE
        
        attrs.drag.left = event.clientX;
        attrs.drag.top  = event.clientY;
        attrs.start.left = marquee.position().left;
        attrs.start.top  = marquee.position().top;
        attrs.isDragged  = true;         

        marquee.css({
          'cursor': 'default', 
          'cursor': '-moz-grabbing',
          'cursor': '-webkit-grabbing'          
        });
           
        return false;
      },
      
      mousemove: function(event) {
        var maxLeft, maxTop;
        
        if (!event) { event = window.event; } // required for IE
        
        if (attrs.isDragged) {
          attrs.left = attrs.start.left + (event.clientX - attrs.drag.left);      
          attrs.top = attrs.start.top + (event.clientY - attrs.drag.top);
  
          // limit marquee dragging to within the marquee background image
          maxLeft = marqueeAttrs.imgWidth - marquee.width();
          maxTop  = marqueeAttrs.imgHeight - marquee.height();
  
          // validate positioning values
          if (attrs.left < 0) { attrs.left = 0; } 
          if (attrs.top < 0) { attrs.top = 0; } 
          
          if (attrs.left > maxLeft) { attrs.left = maxLeft; }
          if (attrs.top > maxTop) { attrs.top = maxTop; }
          
          marquee.css({
            'left': attrs.left + 'px',
            'top': attrs.top + 'px'
          });                    
        }        
      }      
    });

    marquee.ondragstart = function() { return false; } // for IE    
    //$(document).mouseup(function() { stopMarqueeMove();  });
    marquee.mouseup(function() { stopMarqueeMove();  });

    function stopMarqueeMove() {
      attrs.isDragged = false;      
      marquee.css({ 'cursor': '' });

      imgFrameAttrs.relativeLoc.x = ((marquee.position().left + (marquee.width() / 2)) / marqueeAttrs.imgWidth).toFixed(2);
      imgFrameAttrs.relativeLoc.y = ((marquee.position().top + (marquee.height() / 2)) / marqueeAttrs.imgHeight).toFixed(2);
      positionImgFrame();      
    }            
  }
  
  
  /* setup marquee box, background image and marquee  */
  function setupMarquee() {
    var level = util.clampLevel(getLevelForContainer(settings.marqueeImgSize) + 1);
    var marqueeBoxId = viewFinderId + '-marquee-box';
    var marqueeBgId = viewFinderId + '-marquee-bg';    
    var marqueeId = viewFinderId + '-marquee';        
    var minMarqueeImgSize = 50;
    var marqueeURL;
    
    // if marquee image size is too small, it becomes unusable. So, don't render it
    if (settings.marqueeImgSize < minMarqueeImgSize) {
      return;
    }
    
    // remove marquee if already present
    if ($('#' + marqueeBoxId).length != 0) {
      $('#' + marqueeBoxId).remove();
    }
    
    storeRelativeLocation();
    setMarqueeImgDimensions();
             
    marqueeURL = jp2.imgURL + '.jpg?w=' + marqueeAttrs.imgWidth + '&h=' + marqueeAttrs.imgHeight + '&rotate=' + currentRotation;   
      
    viewFinder
    .append($('<div>', { 'id': marqueeBoxId, 'class': 'zpr-marquee-box' })
      .append($('<div>', { 'id': marqueeBgId }))    
    );    
      
    // append marquee to div with marquee background image  
    $('#' + marqueeBgId)
    .css({
      'height': (marqueeAttrs.imgHeight + 4) + 'px', // 4 = marquee border  
      'width':  (marqueeAttrs.imgWidth + 4) + 'px', // 4 = marquee border
      'position': 'relative', 
      'background': '#fff url(\'' + marqueeURL + '\')  no-repeat center center'  
    })
    .append($('<div>', { 
      'id': marqueeId, 
      'class': 'zpr-marquee'      
    }));
        
    setupMarqueeDragging();
    drawMarquee();
  }


  /* draw marquee and position it */
  function drawMarquee() {    
    var left = Math.ceil((imgFrameAttrs.relativeLoc.x * marqueeAttrs.imgWidth) - (marqueeAttrs.width / 2));
    var top = Math.ceil((imgFrameAttrs.relativeLoc.y * marqueeAttrs.imgHeight) - (marqueeAttrs.height / 2));
    
    $('#' + viewFinderId + '-marquee').css({
      'left': left + 'px',
      'top': top + 'px',
      'height': marqueeAttrs.height + 'px',
      'width': marqueeAttrs.width + 'px'                  
    });
  }


  /* set initial marquee dimensions */
  function setMarqueeImgDimensions() {
    var aspectRatio = (jp2.width / jp2.height).toFixed(2);

    marqueeAttrs.imgWidth  = Math.round(settings.marqueeImgSize * aspectRatio);                  
    marqueeAttrs.imgHeight = settings.marqueeImgSize;
       
    if (aspectRatio > 1) {
      marqueeAttrs.imgWidth  = settings.marqueeImgSize;
      marqueeAttrs.imgHeight = Math.round(settings.marqueeImgSize / aspectRatio);            
    }
    
    setMarqueeDimensions();
  }  
    
  function setMarqueeDimensions() {
    marqueeAttrs.width  = Math.ceil((viewFinder.width() / imgFrameAttrs.proportionalWidth) * marqueeAttrs.imgWidth) - 4;
    marqueeAttrs.height = Math.ceil((viewFinder.height() / imgFrameAttrs.proportionalHeight) * marqueeAttrs.imgHeight) - 4;    
  }

  /* utility functions */
  var util = {
    // clamp jp2 level between 0 and max level 
    clampLevel: function(level) {
      if (level < 0) { level = 0; }
      if (level > jp2.levels) { level = jp2.levels; }    
      return level;
    },
    
    // get image stacks zoom value (0 to 100) for a level
    getZoomFromLevel: function(level) {
      var zoom = 0;
      
      level = util.clampLevel(level);
      zoom = (100 / Math.pow(2, jp2.levels - currentLevel)).toFixed(5);
      
      return zoom;
    },    
    
    // check if value is defined
    isValid: function(value) {
      return (typeof value !== 'undefined');
    },
    
    // check if value is a valid length (positive number > 0)
    isValidLength: function(value) {
      if (typeof value !== 'undefined') {
        value = parseInt(value, 10);
        
        if (value > 0) {
          return true;    
        }
      } 
      
      return false;
    }
  };
  
  init();
}
