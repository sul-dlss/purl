class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: [:options]

  helper_method :current_user
  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlVersion::ObjectNotReady, with: :object_not_ready

  def current_user
    request.env['REMOTE_USER']
  end

  def current_user?
    current_user.present?
  end

  def options
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Accept'
    response.headers['Access-Control-Max-Age'] = 1.day.to_i

    head :ok
  end

  private

  def invalid_druid
    render '/errors/invalid', status: :not_found
  end

  def object_not_ready
    render '/errors/unavailable', formats: [:html], status: :not_found
  end
end
