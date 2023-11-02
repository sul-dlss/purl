# frozen_string_literal: true

class FeedbackFormsController < ApplicationController
  def new; end

  def create
    if pass_captcha?
      FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
      flash[:success] = 'Thank you! Your feedback has been sent.'
    else
      flash[:error] = 'You must pass the reCAPTCHA challenge'
    end

    redirect_to params[:url]
  end

  protected

  def pass_captcha?
    current_user.present? || verify_recaptcha
  end
end
