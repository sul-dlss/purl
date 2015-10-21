module Purl
  module Util
    # get id from JP2 filename
    def get_jp2_id(filename)
      filename = filename.gsub(/\.jp2$/i, '')
      filename
    end

    # check if file is ready (deliver = yes or publish = yes)
    def file_ready?(file)
      file && (file['deliver'] != 'no' || file['publish'] != 'no')
    end

    # construct base URL using stacks URL
    def get_img_base_url(pid, deliverable_file)
      img_id = get_jp2_id(deliverable_file.filename.to_s)
      base_url = deliverable_file.imagesvc.to_s

      base_url = Settings.stacks.url + '/image/' + pid + '/' + img_id if base_url.empty?

      base_url
    end

    # get file label (if available) or jp2 id
    def get_file_label(deliverable_file)
      label = get_jp2_id(deliverable_file.filename.to_s)

      label = deliverable_file.label.to_s unless deliverable_file.label.blank?

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

    module_function :get_jp2_id, :get_img_base_url, :get_file_label, :get_file_url, :file_ready?
  end
end
