# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pastes with Forbidden Terms' do
  describe 'POST /pastes' do
    let(:paste_params) { { title: 'normal title', author: 'normal author', code: 'normal code' } }
    let(:create_paste) do
      post '/pastes', params: { paste: paste_params }, headers: { 'Content-Type': 'application/json' }, as: :json
      response.parsed_body
    end

    context 'when a forbidden term matches the title (substring) and action is mark_spam' do
      before { Term.create!(subject: 'title', action: 'mark_spam', content: 'buy_crypto', regex: false) }

      let(:paste_params) { super().merge(title: 'this is a buy_crypto post') }

      it 'marks the paste as spam' do
        create_paste
        expect(Paste.last.marked_kind).to eq('spam')
      end
    end

    context 'when a forbidden term matches the author (regex) and action is remove' do
      before { Term.create!(subject: 'author', action: 'remove', content: '^bad.*author$', regex: true) }

      let(:paste_params) { super().merge(author: 'bad_hacker_author') }

      it 'sets the remove_at to 5 seconds from now' do
        freeze_time do
          create_paste
          expect(Paste.last.remove_at).to eq(5.seconds.from_now)
        end
      end
    end

    context 'when a forbidden term matches the code (substring) and action is remove' do
      before { Term.create!(subject: 'code', action: 'remove', content: 'eval(bad)', regex: false) }

      let(:paste_params) { super().merge(code: 'print("hello"); eval(bad);') }

      it 'sets the remove_at to 5 seconds from now' do
        freeze_time do
          create_paste
          expect(Paste.last.remove_at).to eq(5.seconds.from_now)
        end
      end
    end

    context 'when a forbidden term matches the code (regex) and action is mark_spam' do
      before { Term.create!(subject: 'code', action: 'mark_spam', content: 'v[i1]agra', regex: true) }

      let(:paste_params) { super().merge(code: 'buy some v1agra today') }

      it 'marks the paste as spam' do
        create_paste
        expect(Paste.last.marked_kind).to eq('spam')
      end
    end

    context 'when no forbidden term matches' do
      before { Term.create!(subject: 'code', action: 'mark_spam', content: 'bad_word', regex: false) }

      # rubocop:disable RSpec/ExampleLength
      it 'leaves the paste as unclassified and with default remove_at', :aggregate_failures do
        freeze_time do
          create_paste
          paste = Paste.last
          expect(paste.marked_kind).to eq('ham')
          expect(paste.remove_at).to be > 5.seconds.from_now
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
