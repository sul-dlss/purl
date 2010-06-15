require "dor/util"

class PurlController < ApplicationController

  before_filter :validate_id

  # entry point into the application
  def index
    @purl = Purl.new
    @purl.retrieve_metadata(params[:id])
    if(@purl.xml == '')
      render :file => "purl/unavailable.html.erb", :layout => "layouts/unavailable.html.erb"
    else
      respond_to do |format|
        format.xml { render :xml => @purl.xml }
        format.html
      end
    end
  end

  private

  def validate_id
    # validate that the id is of the proper format
    if( !Dor::Util.validate_druid(params[:id]) )
      # TODO : dougkim
      # render some formatted page instead of a 404 page
      render :status => 404, :file => "#{RAILS_ROOT}/public/404.html"
      return false
    end
    
    # validate that the id exists in the digital object repository
    if( !Dor::Util.exists_resource(params[:id]) )
      render :status => 404, :file => "#{RAILS_ROOT}/public/404.html"
      return false
    end

    # at the point assume the id is valid and the resource exists
    true
  end
  
end

