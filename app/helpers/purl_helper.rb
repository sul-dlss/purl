require 'uri'
require 'purl/util.rb'

module PurlHelper

  # get id from JP2 filename
  def get_jp2_id(filename)
    PurlUtils.get_jp2_id(filename)
  end

  # construct JSON array for delivering image objects
  def get_image_json_array
    PurlUtils.get_image_json_array(@purl.deliverable_files)
  end

  # construct base URL using stacks URL
  def get_img_base_url(deliverable_file)
    PurlUtils.get_img_base_url(@purl.pid, STACKS_URL, deliverable_file)
  end

  # get file label (if available) or jp2 id
  def get_file_label(deliverable_file)
    PurlUtils.get_file_label(deliverable_file)
  end

  # get file URL (for type != image)
  def get_file_url(pid, deliverable_file)
    PurlUtils.get_file_url(pid, deliverable_file)
  end

  # check if file is ready (deliver = yes or publish = yes)
  def is_file_ready(file)
    PurlUtils.is_file_ready(file)
  end


  # get field value
  #
  def print_field_value(field_name, label = '', separator = ' ', add_links_to_URIs = false)
    html = ''
    value = eval("@purl.#{field_name}")
    output = value

    if not(@purl.nil? or value.nil? or value.empty?)
      html = "<dt>" + label + ":</dt><dd>"

      # if array, join using given separator
      if value.is_a?(Array)
        output = value.join(separator)
      end

      if add_links_to_URIs
        output = add_links_to_URIs(output)
      end

      html += output + "</dd>".html_safe
    end

    html = html.html_safe
  end


  # get field value with extracted URIs in HTML tags
  def add_links_to_URIs(str)
    output = str

    # http://www.regular-expressions.info/email.html
    regex_email = /[A-Z0-9_\.%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)/i

    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    regex_url = /(?i)\b(?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?])/i

    str.scan(regex_email).uniq.each do |uri|
      output = output.gsub(/#{uri}/, '<a href="mailto:' + uri + '">' + uri + '</a>')
    end

    str.scan(regex_url).uniq.each do |uri|
      output = output.gsub(/#{uri}/, '<a href="' + uri + '">' + uri + '</a>')
    end

    output.html_safe
  end


  # get field value
  def print_description_value(label = '', add_links_to_URIs = false)
    html = ''

    if not(@purl.nil? or @purl.description.nil? or @purl.description.empty?)
      html = "<dt>" + label + ":</dt><dd>"

      @purl.description.each do |desc|
        if add_links_to_URIs
          desc = add_links_to_URIs(desc)
        end

        desc = desc.gsub(/(\n|\\n|&amp;#10;|&#10;|&#xA;)/, '<br/>')
        html += "<p><span class=\"desc-content\">" + desc + "</span></p>"
      end

      html += "</dd>"
    end

    html.html_safe
  end

  # get title value
  def print_title_value()
    title = ''

    if not(@purl.nil? or @purl.titles.nil? or @purl.titles.empty?)
      title = @purl.titles.join(" -- ")
    end

    title.html_safe
  end

  # get creator(s) value
  def print_creator_value(label = '')
    html = ''

    if not(@purl.nil? or @purl.creators.nil? or @purl.creators.empty?)
      html = "<dt>" + label + ":</dt><dd>" + @purl.creators.join("<br/>") + "</dd>"
    end

    html.html_safe
  end

  # get searchworks link
  def get_searchworks_link
    link = ''
    catkey = @purl.catalog_key

    if not(catkey.nil? or catkey.empty?)
      link = "<a href=\"http://searchworks.stanford.edu/view/" + catkey + "\">View in SearchWorks</a>"
    end

    link.html_safe
  end


  # print 'dc:relation type="url"' value
  def print_relation_url(label = '', separator = ' ')
    html = ''

    if not(@purl.nil? or @purl.relation_url.nil? or @purl.relation_url.empty?)
      html = "<dt>" + label + ":</dt><dd>"

      @purl.relation_url.each do |item|
        html += "<a href=\"" + item['url'] + "\">" + item['label'] + "</a>" + separator
      end

      html += "</dd>"
    end

    html.html_safe
  end


  # get download links
  def get_download_links
    links = []

    @purl.downloadable_files.each do |downloadable_file|
      if !downloadable_file.filename.nil?
        link_label = downloadable_file.filename

        if not(downloadable_file.description_label.nil? or downloadable_file.description_label.empty?)
          link_label = downloadable_file.description_label
        end

        if downloadable_file.rights_stanford || downloadable_file.rights_world
          link = "<a href=\"" + STACKS_URL + "/file/druid:" + @purl.pid + "/" + downloadable_file.filename + "\">" + link_label + "</a>"
        else
          link = link_label
        end

        if not(downloadable_file.size.nil? or downloadable_file.size.empty?)
          link += " (" + number_to_human_size(downloadable_file.size,:precision => 1) + ")"
        end

        link += "&nbsp; <img src=\"/images/icon-download.png\">"

        links.push(link)
      end
    end

    links.each do |link|
      link.html_safe
    end
    links
  end


  # get links for side bar
  def get_sidebar_links
    html = ''

    if !get_searchworks_link.nil?
      html += "<p>" + get_searchworks_link + "</p>"
    end

    if get_download_links.size > 0
      html += "<br/><p><strong>Available download formats:</strong> </p> <ul>"

      get_download_links.each do |link|
        html += "<li>" + link + "</li>"
      end

      html += "</ul>"
    end

    html.html_safe
  end

  # convert date string to YYYY-MM-DD
  def format_date_string(str)
    DateTime.parse(str).strftime('%Y-%m-%d')
  end

  # get embargo text
  def get_embargo_text
    text = ""

    if !embargoExpired
      text = @purl.read_group == "none" ? "Restricted" : "Stanford only"
      text = "Access: " + text + " until " + format_date_string(@purl.embargo_release_date).to_s
    end

    text
  end

  def embargoExpired
    expired = true

    if !@purl.embargo_release_date.nil? and !@purl.embargo_release_date.empty?
      expired = Date.parse(@purl.embargo_release_date.to_s) < Date.today
    end

    expired
  end


  # remove trailing period from name
  def add_copyright_symbol(copyright_stmt)
    copyright_stmt = copyright_stmt.gsub /\(c\) Copyright/i, '&copy; Copyright'
    copyright_stmt.html_safe
  end

  # get number of gallery items per page
  def get_gallery_items_per_page_count
    return 15
  end

  # prune text
  def trim_text(text)
    text = text.gsub /\s+/, ' '
    text = text.gsub /[\n\r]/, ''
    text
  end

  # get first deliverable image file
  def get_first_deliverable_image_file
    @purl.deliverable_files.each do |deliverable_file|
      if deliverable_file.mimetype == "image/jp2"
        return deliverable_file
      end
    end

    return nil
  end

end
