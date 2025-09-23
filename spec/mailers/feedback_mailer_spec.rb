# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailer do
  describe '#submit_feedback' do
    let(:params) do
      {
        name: 'John Doe',
        to: 'user@example.com',
        message: 'This is a test feedback message',
        url: 'https://purl.stanford.edu/test',
        user_agent: 'Mozilla/5.0 (Test Browser)',
        viewport: '1920x1080'
      }
    end
    let(:request_ip) { '192.168.1.1' }
    let(:mail) { described_class.submit_feedback(params, request_ip) }

    before do
      allow(Settings.feedback).to receive(:email_to).and_return('feedback@stanford.edu')
    end

    context 'when optional parameters are missing' do
      let(:params) do
        {
          message: 'This is a test feedback message'
        }
      end

      it 'handles missing parameters gracefully' do
        expect(mail.subject).to eq('Feedback from PURL')
        expect(mail.body.encoded).to match('No name given')
        expect(mail.body.encoded).to match('No email given')
        expect(mail.body.encoded).to match('This is a test feedback message')
      end
    end

    it 'includes all expected content' do
      expect(mail.subject).to eq('Feedback from PURL')
      expect(mail.to).to eq(['feedback@stanford.edu'])
      expect(mail.from).to eq(['feedback@purl.stanford.edu'])

      body = mail.body.encoded

      expect(body).to include('Name: John Doe')
      expect(body).to include('Email: user@example.com')
      expect(body).to include('Comment:')
      expect(body).to include('This is a test feedback message')
      expect(body).to include('Message sent from: https://purl.stanford.edu/test')
      expect(body).to include('Host:')
      expect(body).to include('IP: 192.168.1.1')
      expect(body).to include('User agent: Mozilla/5.0 (Test Browser)')
      expect(body).to include('Viewport: 1920x1080')
    end
  end
end
