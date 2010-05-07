require 'net/https'

module Dor
  
  class DorService

    # retrieve the contents of the given datastream for the given id
    def get_datastream_contents(id,datastream)
      if( datastream == 'rightsMetadata' )
        return get_rights_datastream_contents
      else
        url = "#{FEDORA_URL}/objects/druid:#{id}/datastreams/#{datastream}/content"
        Connection.get(url)
      end
    end

    private

    def get_rights_datastream_contents
      rights_metadata = "<rightsMetadata>
                          <copyright>
                            <human type=\"copyright\">This work is in the Public Domain.</human>
                            <human type=\"copyright\">(c) 2009 by Jasper Wilcox. All rights reserved.</human>
                            <machine>... any good example? ...</machine>
                          </copyright>
                          <access type=\"discover\">
                          </access>
                          <access type=\"read\">
                            <human>This document is available only to the Stanford faculty, staff and student community</human>
                            <machine>
                              <policy>druid:hx551yt4502</policy>
                              <agent>application_id</agent>
                              <person>author_id</person>
                              <group>stanford:faculty</group>
                              <group>stanford:staff</group>
                              <group>stanford:student</group>
                              <embargo>2011-03-01</embargo>
                              <externalVisibility>100</externalVisibility>
                            </machine>
                          </access>
                          <use>
                            <human type=\"statement\">You are free to re-distribute this object with attribution to the author, but you cannot change it or sell it.</human>
                            <machine type=\"creativecommons\">Non-commercial, attribution... src=\"http://i.creativecommons.org/l/by-nc-nd/3.0/us/88x31.png\"</machine>
                          </use>
                        </rightsMetadata>"
    end
    
  end

end
