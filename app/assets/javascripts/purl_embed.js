(function($) {
  $(document).on("ready turbolinks:load", function(){
    $("a.embed").each(function() {
      $.fn.oembed.providers = [
        new $.fn.oembed.OEmbedProvider("purl", "rich", [$(this).attr('href')], $(this).data('oembed-provider'), {
          dataType: 'json'
        }),
      ];

      $(this).oembed();
    });
  });

})(jQuery);
