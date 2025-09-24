# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackFormsController, type: :controller do
  before do
    allow(Settings.feedback).to receive(:email_to).and_return('feedback@example.com')
    allow(controller).to receive_messages(verify_recaptcha: verify, current_user:)
    allow(FeedbackMailer).to receive(:submit_feedback).and_return(mailer)
  end

  let(:verify) { false }
  let(:current_user) { nil }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  describe 'validate' do
    context 'when the user is not logged in and captcha fails' do
      it 'returns an error if the recaptcha is incorrect' do
        post :create, params: { message: 'I am spamming you!', url: 'http://purl.stanford.edu/' }
        expect(flash[:error]).to eq 'You must pass the reCAPTCHA challenge'
        expect(FeedbackMailer).not_to have_received(:submit_feedback)
      end
    end

    context 'when the user is not logged in and captcha succeeds' do
      let(:verify) { true }

      it 'returns success and sends email' do
        post :create, params: { message: 'I am spamming you!', url: 'http://purl.stanford.edu/' }

        expect(flash[:success]).to eq 'Thank you! Your feedback has been sent.'
        expect(controller).to have_received(:verify_recaptcha)
        expect(FeedbackMailer).to have_received(:submit_feedback)
      end
    end

    context 'when the user is logged in' do
      let(:current_user) { 'chester' }

      it 'returns success and sends email' do
        post :create, params: { message: 'I am spamming you!', url: 'http://purl.stanford.edu/' }
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq 'Thank you! Your feedback has been sent.'
        expect(controller).not_to have_received(:verify_recaptcha)
        expect(FeedbackMailer).to have_received(:submit_feedback)
      end
    end
  end
end
