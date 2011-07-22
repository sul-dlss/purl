
module PurlHelper

  #
  # This method round the given number to the given number of decimal points
  #
  def round_to(num,decimals=0)
    factor = 10.0**decimals
    (num*factor).round / factor
  end

  #
  # This method returns the pair tree directory structure based on the given object identifier.
  # The object identifier must be of the following format, otherwise nil is returned.
  #
  #     druid:xxyyyxxyyyy
  #
  #       where 'x' is an alphabetic character
  #       where 'y' is a numeric character
  #
  def create_pair_tree(pid)
    if(pid =~ /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/)
      return File.join($1, $2, $3, $4)
    else
      return nil
    end
  end

  # get id from JP2 filename
  def get_jp2_id(filename)
    filename = filename.gsub /\.jp2$/i, ''
    return filename
  end

  # construct JSON array for delivering image objects
  def get_image_json_array
    json_array = Array.new
    
    @purl.deliverable_files.each do |deliverable_file|
      json_array.push(
        "{ \"id\": \"" +  get_jp2_id(deliverable_file.filename.to_s) + "\"," + 
	      "\"width\": " + deliverable_file.width.to_s + "," + 
	      "\"height\": " + deliverable_file.height.to_s + 
	      "}")
    end   
    
    return json_array.join(',')
  end

  # construct base URL using stacks URL
  def get_img_base_url(deliverable_file)
    img_id = get_jp2_id(deliverable_file.filename.to_s)
    base_url = deliverable_file.imagesvc.to_s
    
    if (base_url.empty?)
      base_url = STACKS_URL + "/image/" + img_id[0..10] + "/" + img_id
    end
    
    return base_url
  end

  # get file label (if available) or jp2 id
  def get_file_label(deliverable_file)
    label = get_jp2_id(deliverable_file.filename.to_s)
    
    if (!deliverable_file.description_label.nil? && !deliverable_file.description_label.empty?)
      label = deliverable_file.description_label.to_s
    end
    
    return label
  end
end
