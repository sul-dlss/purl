class FeedbackMailer < ActionMailer::Base
  def submit_feedback(params, ip)
    if params[:name].present?
      @name = params[:name]
    else
      @name = 'No name given'
    end

    if params[:to].present?
      @email = params[:to]
    else
      @email = 'No email given'
    end

    @message = params[:message]
    @url = params[:url]
    @ip = ip
    @user_agent = params[:user_agent]
    @viewport = params[:viewport]

    mail(:to => Settings.feedback.email_to,
         :subject => "Feedback from PURL",
         :from => "feedback@purl.stanford.edu",
         :reply_to => Settings.feedback.email_to)
  end
end
