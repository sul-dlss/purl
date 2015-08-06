class FeedbackFormsController < ApplicationController
  def new
  end

  def create
    if request.post?
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
  end

  protected

  def validate
    errors = []
    if params[:message].nil? || params[:message] == ''
      errors << 'A message is required'
    end
    if params[:email_address] && params[:email_address] != ''
      errors << 'You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields.'
    end
    flash[:error] = errors.join('<br/>') unless errors.empty?
    flash[:error].nil?
  end
end
