class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: [:options]

  helper_method :current_user

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

  def faq; end

  private

  def invalid_druid
    render '/errors/invalid', status: :not_found
  end

  def object_not_ready
    render '/errors/unavailable', status: :not_found
  end
end
