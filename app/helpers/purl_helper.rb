
module PurlHelper

  # Method to round the given number to the given number of decimal points
  def round_to(num, decimals=0)
    factor = 10.0**decimals
    (num*factor).round / factor
  end

  # get id from JP2 filename
  def get_jp2_id(filename)
    filename = filename.gsub /\.jp2$/i, ''
    filename
  end

  # construct JSON array for delivering image objects
  def get_image_json_array
    json_array = Array.new
    
    @purl.deliverable_files.each do |deliverable_file|
      id     = get_jp2_id(deliverable_file.filename.to_s)
      width  = deliverable_file.width.to_s.empty? ? '0' : deliverable_file.width.to_s
      height = deliverable_file.height.to_s.empty? ? '0' : deliverable_file.height.to_s
      
      if !id.nil? and !id.empty?
        json_array.push(
          "{ \"id\": \"" +  get_jp2_id(deliverable_file.filename.to_s) + "\"," + 
             "\"label\": \"" + get_file_label(deliverable_file) + "\"," + 
  	         "\"width\": " + width.to_s + "," + 
  	         "\"height\": " + height.to_s + "," + 
  	         "\"sequence\": " + deliverable_file.sequence.to_s + 
  	      "}")
  	  else 
  	    if deliverable_file.sub_resources.length > 0 
  	      deliverable_file.sub_resources.each do |img_file|
            id     = get_jp2_id(img_file.filename.to_s)
            width  = img_file.width.to_s.empty? ? '0' : img_file.width.to_s
            height = img_file.height.to_s.empty? ? '0' : img_file.height.to_s

            if !id.nil? and !id.empty?
              json_array.push(
                "{ \"id\": \"" +  get_jp2_id(img_file.filename.to_s) + "\"," + 
                   "\"label\": \"" + get_file_label(img_file) + "\"," + 
        	         "\"width\": " + width.to_s + "," + 
        	         "\"height\": " + height.to_s + "," +  
        	         "\"sequence\": " + deliverable_file.sequence.to_s + 
        	      "}")
        	  end      	        
  	      end
        end    
	    end  
    end   
    
    json_array.join(',')
  end

  # construct base URL using stacks URL
  def get_img_base_url(deliverable_file)
    img_id = get_jp2_id(deliverable_file.filename.to_s)
    base_url = deliverable_file.imagesvc.to_s
    
    if base_url.empty?
      base_url = STACKS_URL + "/image/" + @purl.pid + "/" + img_id
    end
    
    if @purl.pid == "dm907qj6498"
      base_url = base_url.gsub /\-test/i, ''
    end
    
    base_url
  end

  # get file label (if available) or jp2 id
  def get_file_label(deliverable_file)
    label = get_jp2_id(deliverable_file.filename.to_s)
    
    if (!deliverable_file.description_label.nil? && !deliverable_file.description_label.empty?)
      label = deliverable_file.description_label.to_s
    end
    
    if label.length > 45
      label = label[0 .. 44] + '...'
    end
    
    label
  end
  
  # get field value
  def print_field_value(field_name, label = '')
    html = ''
    
    if not(@purl.nil? or eval("@purl.#{field_name}.nil?") or eval("@purl.#{field_name}.empty?"))
      html = "<dt>" + label + ":</dt><dd>" + eval("@purl.#{field_name}.to_s") + "</dd>"
    end
    
    html
  end
  
  # remove trailing period from name
  def add_copyright_symbol(copyright_stmt)
    copyright_stmt = copyright_stmt.gsub /\(c\) Copyright/i, '&copy;'
    
    copyright_stmt
  end
end
