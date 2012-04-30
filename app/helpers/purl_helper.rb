require 'lib/purl/util'

module PurlHelper

  # Method to round the given number to the given number of decimal points
  def round_to(num, decimals=0)
    factor = 10.0**decimals
    (num*factor).round / factor
  end

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
  def print_field_value(field_name, label = '')
    html = ''
    
    if not(@purl.nil? or eval("@purl.#{field_name}.nil?") or eval("@purl.#{field_name}.empty?"))
      html = "<dt>" + label + ":</dt><dd>" + eval("@purl.#{field_name}.to_s") + "</dd>"
    end
    
    html
  end

  # get field value
  def print_description_value(label = '')
    html = ''
    
    if not(@purl.nil? or @purl.description.nil? or @purl.description.empty?)
      html = "<dt>" + label + ":</dt><dd>"

      @purl.description.each do |d|
        html = html + "<p><span class=\"desc-content\">" + d + "</span></p>"
      end

      html = html + "</dd>"
    end
        
    html
  end

  
  # remove trailing period from name
  def add_copyright_symbol(copyright_stmt)
    copyright_stmt = copyright_stmt.gsub /\(c\) Copyright/i, '&copy;'    
    copyright_stmt
  end
  
  def get_gallery_items_per_page_count()
    return 15
  end
  
  def trim_text(text)
    text = text.gsub /\s+/, ' '
    text = text.gsub /[\n\r]/, ''
    text
  end
end
