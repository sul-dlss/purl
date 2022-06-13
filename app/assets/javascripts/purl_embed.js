function setupOembed($) {
  $("a.embed").each(function (embed) {
    $.fn.oembed.providers = [
      new $.fn.oembed.OEmbedProvider(
        "purl",
        "rich",
        [$(embed).attr('href')],
        $(embed).data('oembed-provider'),
        { dataType: 'json' }
      ),
    ];

    $(embed).oembed();
  });
}

document.addEventListener("DOMContentLoaded", function () {
  setupOembed(jQuery)
})
