module ImgEmbedHtmlHelper
  def imgEmbedHtml
    purl_server = request.scheme + '://' + request.host_with_port
    purl_server = purl_server.gsub(/image-viewer.stanford.edu/, 'purl.stanford.edu')

    page = [
      '<div class="pe-container">'
    ]
    with_format('html') do
      page << render_to_string(partial: 'embed/img_viewer')
    end
    page.concat([
      '</div>'
    ])

    {
      page: page.join(''),
      peStacksURL: Settings.stacks.url,
      purlServerURL: purl_server,
      pePid: @purl.pid,
      peImgInfo: get_image_json_array
    }
  end

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end
end
