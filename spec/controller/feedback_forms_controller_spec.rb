require 'rails_helper'

describe FeedbackFormsController, type: :controller do
  before do
    allow(Settings.feedback).to receive(:email_to).and_return('feedback@example.com')
  end
  describe 'format json' do
    it 'should return json success' do
      post :create, params: { url: 'http://test.host/', message: 'Hello Kittenz', format: 'json' }
      expect(flash[:success]).to eq 'Thank you! Your feedback has been sent.'
    end
    it 'should return html success' do
      post :create, params: { url: 'http://test.host/', message: 'Hello Kittenz' }
      expect(flash[:success]).to eq 'Thank you! Your feedback has been sent.'
    end
  end
  describe 'validate' do
    it 'should return an error if no message is sent' do
      post :create, params: { url: 'http://test.host/', message: '', email_address: '' }
      expect(flash[:error]).to eq 'A message is required'
    end
    it 'should return an error if a bot fills in the email_address field (email is correct field)' do
      post :create, params: { message: 'I am spamming you!', url: 'http://test.host/', email_address: 'spam!' }
      expect(flash[:error]).to eq 'You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields.'
    end
  end
end
