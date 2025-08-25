# frozen_string_literal: true

class WebauthController < ApplicationController
  def login
    flash[:success] = 'You have been successfully logged in.'

    redirect_back fallback_location: root_url
  end
end
