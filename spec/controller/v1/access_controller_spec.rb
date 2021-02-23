require 'rails_helper'

RSpec.describe V1::AccessController, type: :controller do
  describe 'show' do
    let(:service) { instance_double(AccessService, authorized?: true) }

    before do
      allow(AccessService).to receive(:new)
        .with(identifier: ResourceIdentifier, level: 'read', agent: Agent)
        .and_return(service)
    end

    it 'returns the status' do
      get :show, params: { level: 'read', druid: '12348', file_name: 'bleh.jp2' }
      json = JSON.parse(response.body)
      expect(response).to be_successful
      expect(json).to eq('authorized' => true)
    end
  end
end
