require 'rails_helper'

describe FeedbackFormsController, type: :controller do
  before do
    allow(Settings.feedback).to receive(:email_to).and_return('feedback@example.com')
  end

  describe 'format json' do
    it 'returns json success' do
      post :create, params: { url: 'http://test.host/', message: 'Hello Kittenz', format: 'json' }
      expect(flash[:success]).to eq 'Thank you! Your feedback has been sent.'
    end

    it 'returns html success' do
      post :create, params: { url: 'http://test.host/', message: 'Hello Kittenz' }
      expect(flash[:success]).to eq 'Thank you! Your feedback has been sent.'
    end
  end

  describe 'validate' do
    it 'returns an error if no message is sent' do
      post :create, params: { url: 'http://test.host/', message: '', email_address: '' }
      expect(flash[:error]).to eq FeedbackFormsController::MESSAGE_BLANK_MESSAGE
    end

    it 'returns an error if a bot fills in the email_address field (email is correct field)' do
      post :create, params: { message: 'I am spamming you!', url: 'http://test.host/', email_address: 'spam!' }
      expect(flash[:error]).to eq FeedbackFormsController::EMAIL_PRESENT_MESSAGE
    end

    context 'when the user is not logged in' do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
      end

      it 'returns an error if the recaptcha is incorrect' do
        post :create, params: { message: 'I am spamming you!', url: 'http://test.host/' }
        expect(flash[:error]).to eq FeedbackFormsController::RECAPTCHA_MESSAGE
      end
    end

    context 'when the user is logged in' do
      before do
        allow(controller).to receive(:current_user).and_return('any truthy value, really')
        allow(controller).to receive(:verify_recaptcha)
      end

      it 'does not care if the recaptcha is incorrect' do
        post :create, params: { message: 'I am spamming you!', url: 'http://test.host/' }
        expect(flash[:error]).to be_nil
        expect(controller).not_to have_received(:verify_recaptcha)
      end
    end
  end
end
