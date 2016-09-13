class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user
    request.env['REMOTE_USER']
  end

  def current_user?
    current_user.present?
  end
end
