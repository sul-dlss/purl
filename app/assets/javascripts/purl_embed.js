(function($) {
  $.fn.oembed.providers = [ 
    new $.fn.oembed.OEmbedProvider("purl", "rich", ["purl.stanford.edu/.+"], "//purl.stanford.edu/embed?hide_title=true&hide_metadata=true", {
      dataType: 'json'
    }),
  ]
  
  $(document).on("ready page:load", function(){
     $("a.embed").oembed();
  });

})(jQuery);
