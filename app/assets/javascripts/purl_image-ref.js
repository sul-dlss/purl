/* Function to make an array unique */
Array.prototype.unique = function() { 
  var o = {}, i, l = this.length, r = [];    
  for (i = 0; i < l; i = i+1) o[this[i]] = this[i];    
  for (i in o) r.push(o[i]); return r;
};

$(function() {
  var pi = new purlImage(newImgInfo);
});

/* Main purlImage function comprising private variables and methods */
var purlImage = (function(data) {
  var imgData;
  var groups = [];
  var resizeTimer;
  var constants = { 'djatokaBaseResolution': 92, 'thumbSize': 500 };
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
      setProperties(); 
      groups = groups.unique(); // clear duplicate group ids
            
      console.log(imgData);
    }  
  }

  /* Calculate properties for each file and store them in JSON data object */
  function setProperties() {    
    $.each(imgData, function(index, imgObj) {
      var seq = imgObj.sequence;
      var levels = getJP2NumOfLevels(imgObj.width, imgObj.height);     
      var groupId = parseInt(getGroupIdFromSequence(imgObj['sequence']), 10);

      imgData[index]['num-levels'] = levels;
      imgData[index]['aspect-ratio'] = parseFloat(imgObj['width']/imgObj['height']).toFixed(2);        
      imgData[index]['group-id'] = groupId;
      groups.push(groupId);
      
      $.each(sizes, function(j, size) {
        return (function(s) {
          imgData[index][s] = getDimensionsForSize(index, s);
          imgData[index]['level-for-' + s] = getLevelForSize(s, index);            
        })(size);
      });      
    });
  }

  /* Calculate number of levels for a given JP2 height and width */
  function getJP2NumOfLevels(width, height) {
    var level = 0;
    var longestSideDimension = width > height ? width : height;

    while (longestSideDimension >= constants['djatokaBaseResolution']) {
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
    var levelDiff = imgObj['num-levels'] - getLevelForSize(size, imgIndex);
    
    // 'thumb' -> fixed length on longest side, doesn't depend on JP2 levels
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
    var aspectRatio = parseFloat(imgObj['aspect-ratio']);

    return parseInt(aspectRatio * height, 10);
  }

  /* Calculate aspect-ratio based height for a given width */
  function getAspectRatioBasedHeight(width, imgIndex) {
    var imgObj = imgData[imgIndex]; 
    var aspectRatio = parseFloat(imgObj['aspect-ratio']);  
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
      if (imgId === imgObj['id']) { return i; }        
    });
        
    return -1;
  }

  /* Get dimensions for size 'thumb' */
  function getDimensionsForThumb(imgIndex) {
    var thumbSize = parseInt(constants['thumbSize'], 10);
    var dimensions = getDimensionsToFitBox(thumbSize, thumbSize, imgIndex);

    return { 'width': dimensions[0], 'height': dimensions[1] };
  }

  /*  Get level for a given size */
  function getLevelForSize(size, imgIndex) {
    var imgObj = imgData[imgIndex];
    var level = 0;
  
    // thumb has fixed size (refer constants.thumbSize variable at the top)  
    if (size !== 'thumb') {
      level = parseInt(imgObj['num-levels'] + sizeLevelMapping[size], 10);
    }
  
    return level;
  }

  /* Get group id from the sequence string (e.g. 1 from 1.2)*/
  function getGroupIdFromSequence(sequence) {
    var sequenceInfo = sequence.toString().split(/\./);
    return sequenceInfo[0];
  }

  init();
});



