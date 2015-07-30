module Purl
  module Util
    # get id from JP2 filename
    def get_jp2_id(filename)
      filename = filename.gsub /\.jp2$/i, ''
      filename
    end

    # check if file is ready (deliver = yes or publish = yes)
    def is_file_ready?(file)
      file && (file['deliver'] != 'no' || file['publish'] != 'no')
    end

    # construct JSON array for delivering image objects
    def get_image_json_array(deliverable_files)
      json_array = []

      deliverable_files.each do |deliverable_file|
        id       = get_jp2_id(deliverable_file.filename.to_s)
        width    = deliverable_file.width.to_s.empty? ? 0 : deliverable_file.width.to_i
        height   = deliverable_file.height.to_s.empty? ? 0 : deliverable_file.height.to_i
        sequence = deliverable_file.sequence.to_s.empty? ? '0' : deliverable_file.sequence.to_s

        rights_world         = deliverable_file.rights_world.to_s
        rights_world_rule    = deliverable_file.rights_world_rule.to_s
        rights_stanford      = deliverable_file.rights_stanford.to_s
        rights_stanford_rule = deliverable_file.rights_stanford_rule.to_s

        unless id.blank?
          json_array.push(
            id: get_jp2_id(deliverable_file.filename.to_s),
            label:  get_file_label(deliverable_file),
            width: width,
            height: height,
            sequence: sequence.to_i,
            rightsWorld: rights_world.to_s,
            rightsWorldRule: rights_world_rule.to_s,
            rightsStanford: rights_stanford.to_s,
            rightsStanfordRule: rights_stanford_rule.to_s
          )
        else
          if deliverable_file.sub_resources.length > 0
            deliverable_file.sub_resources.each do |img_file|
              id     = get_jp2_id(img_file.filename.to_s)
              width  = img_file.width.to_s.empty? ? 0 : img_file.width.to_i
              height = img_file.height.to_s.empty? ? 0 : img_file.height.to_i

              rights_world         = img_file.rights_world.to_s
              rights_world_rule    = img_file.rights_world_rule.to_s
              rights_stanford      = img_file.rights_stanford.to_s
              rights_stanford_rule = img_file.rights_stanford_rule.to_s

              unless id.blank?
                json_array.push(
                  id: get_jp2_id(deliverable_file.filename.to_s),
                  label: get_file_label(img_file),
                  width: width,
                  sequence: sequence + '.' + img_file.sequence.to_s
                )
              end
            end
          end
        end
      end

      json_array
    end

    # construct base URL using stacks URL
    def get_img_base_url(pid, deliverable_file)
      img_id = get_jp2_id(deliverable_file.filename.to_s)
      base_url = deliverable_file.imagesvc.to_s

      base_url =  Settings.stacks.url + '/image/' + pid + '/' + img_id if base_url.empty?

      base_url
    end

    # get file label (if available) or jp2 id
    def get_file_label(deliverable_file)
      label = get_jp2_id(deliverable_file.filename.to_s)

      unless deliverable_file.label.blank?
        label = deliverable_file.label.to_s
      end

      label.truncate(45)
    end

    # get file URL (for type != image)
    def get_file_url(pid, deliverable_file)
      url = deliverable_file.url || ''

      if url.blank?
        url = Settings.stacks.url + '/file/druid:' + pid + '/' + deliverable_file.filename
      end

      URI.encode(url)
    end

    module_function :get_jp2_id, :get_image_json_array, :get_img_base_url, :get_file_label, :get_file_url, :is_file_ready?
  end
end