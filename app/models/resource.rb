class Resource
  attr_accessor :objectId, :type, :mimetype, :size, :sequence, :description_label, :filename, :url

  # image related accessors
  attr_accessor :imagesvc, :width, :height, :sequence, :levels 

  # rights metadata accessors
  attr_accessor :rights_world, :rights_world_rule, :rights_stanford, :rights_stanford_rule 
  
  attr_accessor :shelve, :preserve, :deliver  
  
  # nested resource block accessor
  attr_accessor :sub_resources   
end
  
