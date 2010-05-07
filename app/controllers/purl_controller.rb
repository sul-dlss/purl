require "dor/util"

class PurlController < ApplicationController

  before_filter :validate_id

  # entry point into the application
  def index
    @metadata = Purl.extract_metadata( params[:id] )
  end

  private

  def validate_id
    # validate that the id is of the proper format
    if( !Dor::Util.validate_druid(params[:id]) )
      # TODO: render some formatted page instead of a 404 page
      render :status => 404, :file => "#{RAILS_ROOT}/public/404.html"
      return false
    end
    
    # validate that the id exists in the digital object repository
    if( !Dor::Util.exists_resource(params[:id]) )
      return false
    end

    # at the point assume the id is valid    
    true
  end
  
end

