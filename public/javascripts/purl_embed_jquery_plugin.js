(function($) {
  var serverUrls = {
    'test': 'http://purl-test.stanford.edu',
    'prod': 'http://purl-prod.stanford.edu',
    'local': 'http://localhost:3000'
  }

  $.fn.embedPurl = function(config) {
    var serverURL = serverUrls[config.server];
    var $this = $(this);

    if (!isNaN(parseInt(config.width), 10)) {
      $this.width(config.width);
    }

    if (!isNaN(parseInt(config.height), 10)) {
      $this.height(config.height);
    }

    $.ajax({
      type: "GET",
      url: serverURL + '/' + config.druid + '/embed-js',
      contentType: "text/html; charset=utf-8",
      data: { peContainerWidth: $this.width() , peContainerHeight: $this.height() },
      dataType: "html",

      success: function(html) {
        $.each(['purl_embed', 'zpr'], function(index, value) {
          $('head').append('<link rel="stylesheet" href="' + serverURL + '/stylesheets/' + value + '.css" type="text/css" />')
        });

        $.getScript(serverURL + '/javascripts/zpr.js', function() { });
        $.getScript(serverURL + '/javascripts/cselect.js', function() { });

        $.getScript(serverURL + '/javascripts/purl_embed.js', function() {
          $this.html(html);
          var pe = new purlEmbed(peImgInfo, pePid, peStacksURL, config.sequence, config.size);
        });
      },
      error: function() {
        $this.html("Error loading images for " + config.druid);
      }
    });
  };
})(jQuery);