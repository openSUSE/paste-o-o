# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Oldapis', type: :request do
  describe 'POST /index' do
    let!(:paste) do
      post '/', params: params
      response.redirect_url
    end

    let(:info) do
      get paste, as: :json
      get response.redirect_url, as: :json
      JSON.parse(body)
    end

    context 'with a private paste' do
      let(:params) { { title: 'name', name: 'author', code: 'this is the content of the paste', expire: 7 } }

      it 'returns an empty list of pastes' do
        get '/pastes', as: :json

        expect(JSON.parse(body).length).to eq(0)
      end

      it 'you can access the paste' do
        get info['url'], as: :json

        expect(JSON.parse(body)).to eq(info)
      end

      it 'provides you the correct title' do
        expect(info['title']).to eq 'name'
      end

      it 'provides you the correct author' do
        expect(info['author']).to eq 'author'
      end

      it 'sets the correct expiry' do
        expect(Time.zone.parse(info['remove_at']) - Time.zone.now).to be <= 7.days.seconds.to_i
      end

      it 'provides you the correct paste url' do
        get info['content']
        get response.redirect_url
        expect(body).to eq 'this is the content of the paste'
      end
    end

    context 'with a http file upload content' do
      let(:params) do
        { title: 'name', name: 'author', file: fixture_file_upload('file.txt', 'text/plain') }
      end

      it 'provides you the correct paste url' do
        get info['content']
        get response.redirect_url
        expect(body.force_encoding('utf-8')).to eq "🌶️ Hot\n"
      end
    end

    context 'without providing title' do
      let(:params) { { name: 'author', code: 'this is the content of the paste' } }

      it 'is not empty' do
        get info['url'], as: :json

        expect(JSON.parse(body)['title']).to eq 'Untitled Paste'
      end
    end

    context 'without providing author' do
      let(:params) { { title: 'name', code: 'this is the content of the paste' } }

      it 'is not empty' do
        get info['url'], as: :json

        expect(JSON.parse(body)['author']).not_to be_empty
      end
    end

    context 'without providing content' do
      let(:params) { { name: 'author', title: 'name' } }

      it 'is not empty' do
        get paste

        expect(body).to include('Paste failed to save.')
      end
    end
  end

  describe 'GET /:permalink' do
    context 'with non existing paste' do
      it 'redirects to susepaste.org' do
        get "/#{SecureRandom.hex(6)}"

        expect(response.redirect_url).to start_with('https://susepaste.org/')
      end
    end
  end
end
