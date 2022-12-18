# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pastes' do
  describe 'POST /index' do
    let(:type) { :json }
    let!(:paste) do
      post '/pastes', params: { paste: params }, headers: { 'Content-Type': 'application/json' }, as: type
      get response.header['Location'], as: :json if response.header['Content-Type'].include? 'text/html'
      JSON.parse(body)
    end

    context 'with a public paste' do
      let(:params) { { title: 'name', author: 'author', code: 'this is the content of the paste', private: false } }

      it 'returns a non-empty list of pastes' do
        get '/pastes', as: :json

        expect(JSON.parse(body).length).to eq(1)
      end

      it 'lets you can access the paste' do
        get paste['url'], as: :json

        expect(JSON.parse(body)).to eq(paste)
      end

      it 'provides you the correct title' do
        expect(paste['title']).to eq 'name'
      end

      it 'provides you the correct author' do
        expect(paste['author']).to eq 'author'
      end

      it 'provides you the correct paste url' do
        get paste['content']
        get response.redirect_url
        expect(body).to eq 'this is the content of the paste'
      end
    end

    context 'with a private paste' do
      let(:params) { { title: 'name', author: 'author', code: 'this is the content of the paste', private: true } }

      it 'returns an empty list of pastes' do
        get '/pastes', as: :json

        expect(JSON.parse(body).length).to eq(0)
      end

      it 'you can access the paste' do
        get paste['url'], as: :json

        expect(JSON.parse(body)).to eq(paste)
      end

      it 'provides you the correct title' do
        expect(paste['title']).to eq 'name'
      end

      it 'provides you the correct author' do
        expect(paste['author']).to eq 'author'
      end

      it 'provides you the correct paste url' do
        get paste['content']
        get response.redirect_url
        expect(body).to eq 'this is the content of the paste'
      end
    end

    context 'with a http file upload content' do
      let(:params) do
        { title: 'name', author: 'author', content: fixture_file_upload('file.txt', 'text/plain'), private: true }
      end
      let(:type) { nil }

      it 'provides you the correct paste url' do
        get paste['content']
        get response.redirect_url
        expect(body.force_encoding('utf-8')).to eq "🌶️ Hot\n"
      end
    end

    context 'without providing title' do
      let(:params) { { author: 'author', code: 'this is the content of the paste', private: true } }

      it 'title is not empty' do
        get paste['url'], as: :json

        expect(JSON.parse(body)['title']).to eq 'Untitled Paste'
      end
    end

    context 'without providing author' do
      let(:params) { { title: 'name', code: 'this is the content of the paste', private: true } }

      it 'author is not empty' do
        get paste['url'], as: :json

        expect(JSON.parse(body)['author']).not_to be_empty
      end
    end

    context 'without providing content' do
      let(:params) { { title: 'name', author: 'author', private: true } }

      it 'paste fails' do
        expect(JSON.parse(body)['content'].first).to eq("can't be blank")
      end
    end

    context 'without providing private' do
      let(:params) { { title: 'name', author: 'author', code: 'this is the content of the paste' } }

      it 'you can access the paste' do
        expect(JSON.parse(body)['private']).to be true
      end
    end
  end
end
