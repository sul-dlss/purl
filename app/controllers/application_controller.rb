class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user
    request.env['REMOTE_USER']
  end

  def current_user?
    current_user.present?
  end

  private

  def invalid_druid
    render '/errors/invalid', status: 404
  end

  def object_not_ready
    render '/errors/unavailable', status: 404
  end

  def missing_file
    render '/errors/missing_file.html', status: 404
  end
end
