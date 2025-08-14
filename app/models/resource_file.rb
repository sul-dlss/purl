class ResourceFile
  include ActiveModel::Model

  attr_accessor :height, :width, :type, :mimetype, :size, :role, :label, :url,
                :filename, :imagesvc, :druid, :id, :sequence
end
