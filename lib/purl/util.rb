module PurlUtils
  
  # get id from JP2 filename
  def get_jp2_id(filename)
    filename = filename.gsub /\.jp2$/i, ''
    filename
  end

  # check if file is ready (deliver = yes or publish = yes)
  def is_file_ready(file)
    if !file.nil? and not(file['deliver'] == "no" or file['publish'] == "no")
      return true
    end
    
    false
  end

  # construct JSON array for delivering image objects
  def get_image_json_array(deliverable_files)
    json_array = Array.new
    
    deliverable_files.each do |deliverable_file|
      id       = get_jp2_id(deliverable_file.filename.to_s)
      width    = deliverable_file.width.to_s.empty? ? 0 : deliverable_file.width.to_i
      height   = deliverable_file.height.to_s.empty? ? 0 : deliverable_file.height.to_i
      sequence = deliverable_file.sequence.to_s.empty? ? '0' : deliverable_file.sequence.to_s
      access_stanford = deliverable_file.access_stanford.to_s
      access_world = deliverable_file.access_world.to_s
      
      if !id.nil? and !id.empty?
        json_array.push(
          "{ \"id\": \"" +  get_jp2_id(deliverable_file.filename.to_s) + "\"," + 
             "\"label\": \"" + get_file_label(deliverable_file) + "\"," + 
  	         "\"width\": " + width.to_s + "," + 
  	         "\"height\": " + height.to_s + "," + 
  	         "\"sequence\": " + sequence + "," + 
  	         "\"accessStanford\": \"" + access_stanford.to_s + "\"," +  
  	         "\"accessWorld\": \"" + access_world.to_s + "\"" +  	         
  	      "}")
  	  else 
  	    if deliverable_file.sub_resources.length > 0 
  	      deliverable_file.sub_resources.each do |img_file|
            id     = get_jp2_id(img_file.filename.to_s)
            width  = img_file.width.to_s.empty? ? 0 : img_file.width.to_i
            height = img_file.height.to_s.empty? ? 0 : img_file.height.to_i

            if !id.nil? and !id.empty?
              json_array.push(
                "{ \"id\": \"" +  get_jp2_id(img_file.filename.to_s) + "\"," + 
                   "\"label\": \"" + get_file_label(img_file) + "\"," + 
        	         "\"width\": " + width.to_s + "," + 
        	         "\"height\": " + height.to_s + "," +  
        	         "\"sequence\": " + sequence + '.' + img_file.sequence.to_s + 
        	      "}")
        	  end      	        
  	      end
        end    
	    end  
    end   

    json_array.join(',')
  end

  # construct base URL using stacks URL
  def get_img_base_url(pid, stacks_url, deliverable_file)
    img_id = get_jp2_id(deliverable_file.filename.to_s)
    base_url = deliverable_file.imagesvc.to_s
    
    if base_url.empty?
      base_url = stacks_url  + "/image/" + pid + "/" + img_id
    end
    
    if pid == "dm907qj6498"
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
  
  # get file URL (for type != image)
  def get_file_url(pid, deliverable_file) 
    url = deliverable_file.url || ""
    
    if !url.nil? and url.empty?
      url = STACKS_URL + "/file/druid:" + pid + "/" + deliverable_file.filename
    end  
    
    url
  end
  
  module_function :get_jp2_id, :get_image_json_array, :get_img_base_url, :get_file_label, :get_file_url 
end
