
require 'rubygems'
require 'net/http'
require 'uri'
require 'cgi'
require 'rexml/document'
require 'nokogiri'

include REXML

module Dor

  module WorkflowService

  # create workflow
  def WorkflowService.create_workflow(druid)
    full_uri = ''
    full_uri << DOR_URI << '/objects/' << druid << '/workflows/etdSubmitWF'   
    res = Dor::Connection.put(full_uri, XML)
    case res
      when Net::HTTPSuccess
        return true
      else
        raise res.error! + "\n" + res.body
      end
    rescue Exception => e
      puts "Unable to create workflow\n" << e.to_s
    return false
  end
  
  # update workflow
  def WorkflowService.update_workflow_status(druid, workflow, process, status)
    uri = ''
    uri << DOR_URI << '/objects/' << druid << '/workflows/' << workflow << '/' << process
    process_xml = '<process name="'+ process + '" status="' + status + '" '
    process_xml << 'elapsed="0" '
    process_xml << '/>'
    Dor::Connection.put(uri, process_xml) {|response| true}
  end
  
  # retrieve workflow status
  # Copied from lyber-core > 0.9.2
  # TODO: need to use lyber-core
  def WorkflowService.get_workflow_status(repo, druid, workflow, process)
      uri = ''
      uri << Dor::WF_URI << '/' << repo << '/objects/' << druid << '/workflows/' << workflow
      workflow_md = LyberCore::Connection.get(uri)

      doc = Nokogiri::XML(workflow_md)
      raise Exception.new("Unable to parse response:\n#{workflow_md}") if(doc.root.nil?)
      
      status = doc.root.at_xpath("//process[@name='#{process}']/@status").content
      return status
  end
    
  end
end
