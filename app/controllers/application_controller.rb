class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Squash::Ruby::ControllerMethods
  enable_squash_client

  helper_method :current_user

  def current_user
    request.env['REMOTE_USER']
  end

  def current_user?
    current_user.present?
  end
end
