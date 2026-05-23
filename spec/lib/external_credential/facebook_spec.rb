# Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe ExternalCredential::Facebook do
  describe '.request_account_to_link' do
    let(:state) { 'test_oauth_state' }
    let(:client_id) { '123' }
    let(:client_secret) { '456' }
    let(:scope) do
      'pages_show_list, business_management, pages_messaging, read_insights, pages_manage_posts, pages_manage_engagement, pages_manage_metadata, pages_read_engagement, pages_read_user_content'
    end
    let(:authorize_url) do
      "https://www.facebook.com/v16.0/dialog/oauth?client_id=#{client_id}&redirect_uri=http%3A%2F%2Fzammad.example.com%2Fapi%2Fv1%2Fexternal_credentials%2Ffacebook%2Fcallback&response_type=code&scope=#{scope.tr(' ', '+').gsub(',', '%2C')}&state=#{state}"
    end

    before do
      allow(SecureRandom).to receive(:uuid).and_return(state)
    end

    it 'generates an authorize url with the required page permissions' do
      external_credential = create(:external_credential, name: 'facebook', credentials: { application_id: client_id, application_secret: client_secret })

      request = described_class.request_account_to_link(external_credential.credentials)

      expect(request[:request_token]).to eq(state)
      expect(request[:authorize_url]).to include('pages_show_list')
      expect(request[:authorize_url]).to include('business_management')
      expect(request[:authorize_url]).to include('pages_messaging')
      expect(request[:authorize_url]).to include('read_insights')
    end
  end
end
