class WebauthController < ApplicationController
  def login
    flash[:success] = 'You have been successfully logged in.'

    redirect_back fallback_location: root_url
  end

  def logout
    flash[:notice] = 'You have been successfully logged out.'
    redirect_back fallback_location: root_url
  end
end
