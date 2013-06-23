module ImgEmbedHtmlHelper

  def imgEmbedHtml(callback)
    purl_server = request.scheme + "://" + request.host_with_port
    purl_server = purl_server.gsub(/image-viewer.stanford.edu/, 'purl.stanford.edu')
    purl_url = purl_server + "/" + @purl.pid
    callback = callback || 'callback'

    page = [
      '<div class=\"pe-container\">',
        '<div class=\"pe-img-viewer-default pe-img-viewer-thumbs-nav-top\" style=\"display: none;\">'
    ]

    if @purl.deliverable_files.length > 1
      page.concat([
          '<div class=\"pe-h-nav\">',
            '<a class=\"pe-h-nav-prev\"></a>',
            '<img class=\"pe-h-nav-img-01 pe-h-nav-img\" src=\"\">',
            '<div class=\"pe-h-nav-selected-tab\">',
              '<img class=\"pe-h-nav-img-02 pe-h-nav-img pe-h-nav-selected-img\" src=\"\"> <br/>',
            '</div>',
            '<img class=\"pe-h-nav-img-03 pe-h-nav-img\" src=\"\">',
            '<a class=\"pe-h-nav-next\"></a>',
            '<div class=\"pe-h-nav-pagination\"></div>',
          '</div>'
      ])
    end

    page.concat([
          '<div class=\"pe-nav-contents\">',
            '<div class=\"pe-dd-cselect\"></div>',
            '<div class=\"pe-full-screen-nav\">',
              '<img class=\"pe-full-screen-ctrl\" src=\"' + purl_server + '/images/icon-full-screen-expand.png\">',
            '</div>',
            '<div class=\"pe-img-viewfinder\">',
              '<img class=\"pe-img-canvas\" src=\"\" title=\"\" alt=\"\" />',
              '<div id=\"pe-zpr-frame\"></div>',
            '</div>',
          '</div>',
          '<div class=\"pe-purl-url\">',
            '<a href=\"' +  purl_url + '\" target=\"_blank\">' + purl_url + '</a>',
          '</div>',
          '<div class=\"pe-full-screen-close\"></div>'
    ])

    page.concat([
        '</div>',
      '</div>'
    ])

    json = [
      '"page" :"' + page.join('') + '"',
      '"peStacksURL" :"' + STACKS_URL + '"',
      '"purlServerURL" : "' + purl_server + '"',
      '"pePid" :"' + @purl.pid + '"',
      '"peImgInfo" : [' + get_image_json_array + ']'
    ]

    return callback  + '({ ' + json.join(',') + ' });'
    # return '{ ' + json.join(',') + ' }'

  end

end