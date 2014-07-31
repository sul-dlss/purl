require 'net/https'

module Dor
  
  class DorService

    # retrieve the contents of the given datastream for the given id
    def get_datastream_contents(id,datastream)
      begin
        url = "#{Settings.fedora.url}/objects/druid:#{id}/datastreams/#{datastream}/content"
        Connection.get(url)
      rescue
        nil
      end
    end
    
  end

end
