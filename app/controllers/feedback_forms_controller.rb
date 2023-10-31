# frozen_string_literal: true

class FeedbackFormsController < ApplicationController
  EMAIL_PRESENT_MESSAGE = 'You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields.'
  MESSAGE_BLANK_MESSAGE = 'A message is required'
  RECAPTCHA_MESSAGE = 'You must pass the reCAPTCHA challenge'

  # The client handles rendering flash in this case, so clear it on the server
  # side to prevent it from rendering on the next request.
  after_action :discard_flash!, only: :create, if: -> { request.xhr? }

  def new
    return render :new_frame if params[:frame] == 'true'

    render :new
  end

  def create
    if validate
      FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
      flash[:success] = 'Thank you! Your feedback has been sent.'
    end

    respond_to do |format|
      format.json do
        render json: flash
      end
      format.html do
        redirect_to params[:url]
      end
    end
  end

  protected

  def validate
    errors = []
    errors << MESSAGE_BLANK_MESSAGE if params[:message].blank?
    errors << EMAIL_PRESENT_MESSAGE if params[:email_address].present?
    errors << RECAPTCHA_MESSAGE if current_user.blank? && !verify_recaptcha

    flash[:error] = errors.join('<br/>') unless errors.empty?
    flash[:error].nil?
  end

  def discard_flash!
    flash.discard
  end
end
