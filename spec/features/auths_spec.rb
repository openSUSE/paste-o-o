# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auths' do
  context 'when an anonymous user' do
    it 'tries to access auth keys' do
      visit '/auths'
      expect(page).to have_text('You need to log in before accessing that page')
    end
  end

  context 'when a logged in user' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'test@opensuse.org', nickname: 'testing' } })
      visit '/'
      click_button 'Log in'
    end

    it 'tries to access auth keys' do
      visit '/auths'
      expect(page).to have_text('Keys')
    end

    context 'with access to auth creation' do
      before do
        visit '/auths'
        click_on 'Create key'
        fill_in 'auth_name', with: 'new_auth'
        click_button 'Save'
      end

      it 'creates auth key with correct data' do
        expect(page).to have_text('new_auth')
      end

      it 'removes the additional auth' do
        within all('.list-group-item .dropdown').last do
          click_on 'Options'
          click_button 'Remove the key'
        end
        expect(page).to have_text('Key was successfully destroyed.')
      end
    end

    it 'removes the auth the user is logged in as' do
      visit '/auths'
      click_on 'Options'
      click_button 'Remove the key'
      expect(page).to have_text('You need to log in before accessing that page')
    end
  end
end
