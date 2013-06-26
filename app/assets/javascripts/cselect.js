// custom select jQuery plugin (Inspired by ddslick jQuery plugin)
//
(function($) {

  // default values for the plugin
  var config = {
        backgroundColor: '#eee',
        defaultSelectedIndex: null,
        reverseMenuDirection: false,
        selectText: '',
        width: 250,
        onSelected: function() {}
      },

      // CSS for the plugin
      cselectCss = '<style id="cselect-css" text="type/css">.cselect-container{font-family:"Lucida Grande","Lucida Sans Unicode",Arial,Helvetica,sans-serif;font-size:11px;}.cselect{background:#eee url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAeCAIAAABrHEPqAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpCRkY4NzU4MzEwQzExMUUyODVGRUE1MDUyNjlENEI1MSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpCRkY4NzU4NDEwQzExMUUyODVGRUE1MDUyNjlENEI1MSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkJGRjg3NTgxMTBDMTExRTI4NUZFQTUwNTI2OUQ0QjUxIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkJGRjg3NTgyMTBDMTExRTI4NUZFQTUwNTI2OUQ0QjUxIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+QWx6jgAAADpJREFUeNqsx7kJADAMBLB4/3n9P6RNZTiIOtHMnAeh727oVbU+M6FHxHp3x2623lShqwh25p+/AgwA+1BX1nWIuucAAAAASUVORK5CYII=) left top repeat-x;border:1px solid #bbb;border-radius:3px;cursor:pointer;font-weight:bold;padding:8px 0;overflow:auto;position:relative}.cselect .cselect-selected{padding-left:12px}.cselect-arrow{background:transparent url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAMCAYAAABfnvydAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpFRTc5NDk2MDEwQzUxMUUyODVGRUE1MDUyNjlENEI1MSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpFRTc5NDk2MTEwQzUxMUUyODVGRUE1MDUyNjlENEI1MSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkVFNzk0OTVFMTBDNTExRTI4NUZFQTUwNTI2OUQ0QjUxIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkVFNzk0OTVGMTBDNTExRTI4NUZFQTUwNTI2OUQ0QjUxIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+b/cajwAAAHVJREFUeNqEkN0OgCAIRsVaz5R6oU8u+lh2Q+Kmw1bJxvzgMH4EIlJ/pmWQUiZ2mdtniD2kEDyMDg+oWPdOgJgmKM37oGC1JJRS4LcgRqSc0+cI7ZzVLN4gM62IwFmzyaIGa47Z+AdrzqM+F+sG+w6rK24BBgDIIT1CfIxZcAAAAABJRU5ErkJggg==) left top no-repeat;display:block;float:right;height:12px;padding-right:12px;width:8px}.cselect-container ul{background-color:#fff;border:1px solid #bbb;border-radius:3px;box-shadow:0 1px 7px rgba(50,50,50,0.2);display:none;list-style-type:none;margin:0;margin-top:-1px;padding:0;position:absolute;z-index:99000;}.cselect-container ul li{border-top:1px dotted #ccc;cursor:pointer;padding:10px 12px; line-height: 1.3em}.cselect-container ul>:first-child{border-top-width:0}.cselect-container ul li:hover{background-color:#f9f9f9}.cselect-container a:link,.cselect-container a:visited,.cselect-container a:active{text-decoration:none}.cselect-selected-option{background-color:#f0f0f0;}</style>';

      // HTML for the plugin
      cselectHtml = '<div class="cselect"><span class="cselect-selected"></span><span class="cselect-arrow"></span></div>',
      cselectOptionsHtml = '<ul class="cselect-options"></ul>';

  // inject css classes to head (only once)
  if ($('#cselect-css').length <= 0) {
    $(cselectCss).appendTo('head');
  }

  var methods = {
    init: function(options) {
      // merge defaults with user supplied options
      var options = $.extend({}, config, options);

      // apply to all selected elements
      return this.each(function() {
        var obj = $(this);

        // check if plugin is already initialized, and apply
        if (!obj.data('cselectData')) {
          var cselect, cselectOptions, cselectSelected, marginTop;

          // append HTML to container
          obj.addClass('cselect-container').append(cselectHtml).append(cselectOptionsHtml);

          cselect = obj.find('.cselect');
          cselectOptions = obj.find('.cselect-options');
          cselectSelected = obj.find('.cselect-selected');

          // set width
          obj.width(options.width);
          cselectOptions.width(options.width);
          cselect.width(options.width).css({ backgroundColor: options.backgroundColor });

          // add options to select list
          $.each(options.data, function(index, item) {
            if (item.selected && item.selected === true) options.defaultSelectedIndex = index;
            cselectOptions.append('<li>' + item.html + '</li>');
          });

          // save plugin data
          obj.data('cselectData', { settings: options });

          if (options.selectText.length > 0 && !options.defaultSelectedIndex) {
            cselectSelected.html(options.selectText);
          } else {
            selectIndex(obj, getDefaultSelectedIndex(options.defaultSelectedIndex, options.data.length));
          }

          // events
          // open select box with options
          cselect.click(function(event) {
            // do not trigger if the selected option has HTML links
            if ((cselectSelected.has(event.target)).length == 0) {
              open(obj);
            }
          });

          // make options open above
          if (options.reverseMenuDirection) {
            marginTop = (cselect.outerHeight(true) + cselectOptions.outerHeight(true) + 1) * -1;
            cselectOptions.css('margin-top', marginTop);
          }

          // select an options from the list
          cselectOptions.find('li').click(function() {
            selectIndex(obj, $(this).closest('li').index());
          });

          // click anywhere to close
          $('body').click(function(event) {
            var target = event.target || event.srcElement;

            if (target && !/^cselect/.test(target.className)) {
              cselectOptions.slideUp('fast');
            }
          });
        }
      });
    },

    // public: select an option using its index
    select: function(options) {
      return this.each(function() {
        if (options.index) selectIndex($(this), options.index);
      });
    },

    // public: open select box with options
    open: function() {
      return this.each(function() {
        var $this = $(this),
            pluginData = $this.data('cselectData');

        if (pluginData) open($this);
      });
    },

    // public: close select box
    close: function() {
      return this.each(function() {
        var $this = $(this),
            pluginData = $this.data('cselectData');

        if (pluginData) close($this);
      });
    },

    // public: destroy and unbind all events
    destroy: function() {
      return this.each(function() {
        var $this = $(this),
            pluginData = $this.data('cselectData');

        if (pluginData) {
          $this.removeData('cselectData').unbind('.cselect').removeClass('cselect-container').empty();
        }
      });
    }
  };

  // method for select index
  function selectIndex(obj, index) {
    var pluginData      = obj.data('cselectData'),
        cselectSelected = obj.find('.cselect-selected'),
        cselectOptions  = obj.find('.cselect-options'),
        selectedOption  = cselectOptions.find('li').eq(index),
        selectedLiItem  = selectedOption.closest('li'),
        settings        = pluginData.settings,
        selectedData    = pluginData.settings.data[index];

    cselectOptions.find('li').removeClass('cselect-selected-option');
    selectedOption.addClass('cselect-selected-option');

    pluginData.selectedIndex = index;
    pluginData.selectedItem = selectedLiItem;
    pluginData.selectedData = selectedData;

    cselectSelected.html(selectedData.html);

    obj.data('cselectData', pluginData);

    close(obj);

    if (typeof settings.onSelected == 'function') {
      settings.onSelected.call(this, pluginData);
    }
  }

  // open the drop-down select box
  function open(obj) {
    var cselectOptions = obj.find('.cselect-options'),
        isOpen = cselectOptions.is(':visible');

    if (isOpen)
      cselectOptions.slideUp('fast')
    else
      cselectOptions.slideDown('fast');
  }

  // close the drop-down select box
  function close(obj) {
    obj.find('.cselect-options').slideUp(50);
  }

  // get/validate selected index
  function getDefaultSelectedIndex(index, length) {
    return (index && index >= 0 && index < length) ? index : 0;
  }

  // method calling logic (derived from jQuery site)
  $.fn.cselect = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));

    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments);

    } else {
      $.error('Method ' + method + ' does not exist on jQuery.cselect');
    }
  }

})(jQuery);