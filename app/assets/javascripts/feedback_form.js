$(document).on("turbolinks:load", function(){
  // Instantiates plugin for feedback form

  $("#feedback-form").feedbackForm();
});

(function ($, window, document, undefined) {
  /*
    jQuery plugin that handles some of the feedback form functionality

      Usage: $(selector).feedbackForm();

    No available options

    This plugin :
      - submits an ajax request for the feedback form
      - displays alert on response from feedback form
  */

    var pluginName = "feedbackForm";

    function Plugin(element, options) {
        this.element = element;
        var $el, $form;

        this.options = $.extend({}, options);
        this._name = pluginName;
        this.init();
    }

    function submitListener() {
      // Serialize and submit form if not on action url
      $form.each(function(i, form){
        if (location !== form.action){
          $('#user_agent').val(navigator.userAgent);
          $('#viewport').val('width:' + window.innerWidth + ' height:' + innerHeight);
          $(form).on('submit', function(){
            var valuesToSubmit = $(this).serialize();
            $.ajax({
              url: form.action,
              data: valuesToSubmit,
              type: 'post'
            }).done(function(response){
              if (isSuccess(response)){
                // This is the BS5 way to toggle a collapsible
                new bootstrap.Collapse($el);
                $($form)[0].reset();
              }
              renderFlashMessages(response);
            });
            return false;
          });

        }
      });
    }

    function isSuccess(response){
      switch(response[0][0]){
      case 'success':
        return true;
      default:
        return false;
      }
    }

    function renderFlashMessages(response) {
      $.each(response, function(i,val){
        var flashHtml = "<div class='alert alert-" + alertClassFrom(val[0]) + " alert-dismissible' role='alert'>" + val[1] + "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button></div>";

        // Show the flash message
        $('div.flash_messages').html(flashHtml);
      });
    }

    function alertClassFrom(flashLevel) {
      switch(flashLevel) {
      case 'notice':
        return 'info';
      case 'alert':
        return 'warning';
      case 'error':
        return 'danger';
      default:
        return flashLevel;
      }
    }

    Plugin.prototype = {
        init: function() {
          $el = $(this.element);
          $form = $($el).find('form');

          // Add listener for form submit
          submitListener();

          // Updates reporting from fields for current location
          $('span.reporting-from-field').html(location.href);
          $('input.reporting-from-field').val(location.href);

          // Focus message textarea when showing collapsible form
          $('#feedback-form').on('shown.bs.collapse', function () {
            $("textarea#message").focus();
          });
        }
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin(this, options));
            }
        });
    };
})(jQuery, window, document);
