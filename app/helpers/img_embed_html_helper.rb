module ImgEmbedHtmlHelper

  def imgEmbedHtml(callback)
    purl_server = request.scheme + "://" + request.host_with_port
    purl_server = purl_server.gsub(/image-viewer.stanford.edu/, 'purl.stanford.edu')
    purl_url = purl_server + "/" + @purl.pid
    callback = callback || 'callback'

    page = [
      '<div class=\"pe-container\">',
    ]
    with_format("html") do
      page << render_to_string(partial: 'purl/embed/img_viewer')
    end
    page.concat([
      '</div>'
    ])

    json = [
      '"page" :"' + page.join('') + '"',
      '"peStacksURL" :"' + Settings.stacks.url + '"',
      '"purlServerURL" : "' + purl_server + '"',
      '"pePid" :"' + @purl.pid + '"',
      '"peImgInfo" : [' + get_image_json_array + ']'
    ]

    return callback  + '({ ' + json.join(',') + ' });'

  end

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end
end
