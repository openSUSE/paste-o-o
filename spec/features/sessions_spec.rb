# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  context 'when a user logs in' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'test@opensuse.org', nickname: 'testing' } })
      visit '/'
      click_link_or_button 'Log in'
    end

    it 'can see their username' do
      expect(page).to have_text('testing')
    end

    it 'can see their paste link' do
      click_on 'testing'
      click_on 'My Pastes'
      expect(page).to have_text('Listing pastes')
    end

    it 'can see their keys link' do
      click_on 'testing'
      click_on 'My Keys'
      expect(page).to have_text('Keys')
    end

    it 'can log out' do
      click_on 'testing'
      click_link_or_button 'Log Out'
      expect(page).to have_no_text('testing')
    end
  end
end
