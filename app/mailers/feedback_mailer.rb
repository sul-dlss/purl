# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def submit_feedback(params, request_ip)
    @name = params[:name].presence || 'No name given'

    @email = params[:to].presence || 'No email given'

    @message = params[:message]
    @url = params[:url]
    @ip = request_ip
    @user_agent = params[:user_agent]
    @viewport = params[:viewport]

    mail(to: Settings.feedback.email_to,
         subject: 'Feedback from PURL',
         from: 'feedback@purl.stanford.edu',
         reply_to: Settings.feedback.email_to)
  end
end
