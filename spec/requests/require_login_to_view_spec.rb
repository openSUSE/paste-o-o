# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Viewing pastes' do
  let(:user) { User.create!(username: 'apiuser', email: 'api@opensuse.org') }
  let(:auth) { user.auths.create!(name: 'test') }
  let!(:paste_url) do
    post '/pastes', params: { paste: { code: 'visible content', private: false, auth_key: auth.key } },
                    headers: { 'Content-Type': 'application/json' }, as: :json
    response.parsed_body['url']
  end

  context 'when require_login_to_view is off (the default)' do
    it 'lets an anonymous user view the paste' do
      get paste_url, as: :json

      expect(response).to have_http_status(:ok)
    end
  end

  context 'when require_login_to_view is enabled' do
    before do
      allow(Rails.configuration.site).to receive(:[]).and_call_original
      allow(Rails.configuration.site).to receive(:[]).with(:require_login_to_view).and_return(true)
    end

    it 'forbids an anonymous user from viewing the paste' do
      get paste_url, as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it 'still lets an authenticated user view the paste' do
      get paste_url, params: { auth_key: auth.key }, as: :json

      expect(response).to have_http_status(:ok)
    end
  end
end
