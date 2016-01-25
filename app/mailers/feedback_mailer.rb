class FeedbackMailer < ActionMailer::Base
  def submit_feedback(params, ip)
    @name = if params[:name].present?
              params[:name]
            else
              'No name given'
            end

    @email = if params[:to].present?
               params[:to]
             else
               'No email given'
             end

    @message = params[:message]
    @url = params[:url]
    @ip = ip
    @user_agent = params[:user_agent]
    @viewport = params[:viewport]

    mail(to: Settings.feedback.email_to,
         subject: 'Feedback from PURL',
         from: 'feedback@purl.stanford.edu',
         reply_to: Settings.feedback.email_to)
  end
end
