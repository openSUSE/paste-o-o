# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pastes' do
  context 'when an anonymous user creates a new paste' do
    it 'without entering any content' do
      visit '/'
      click_link_or_button 'Save'
      expect(page).to have_text("Content can't be blank")
    end

    it 'with text file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.txt')
      click_link_or_button 'Save'
      expect(page).to have_text('🌶️ Hot')
    end

    context 'with code content' do
      before do
        visit '/'
        fill_in('paste_code', with: 'John')
      end

      it 'creates a valid paste' do
        click_link_or_button 'Save'
        expect(page).to have_text('John')
      end

      it 'without changing the private state' do
        click_link_or_button 'Save'
        expect(page).to have_text('Private')
      end

      it 'with private selected' do
        check('paste_private')
        click_link_or_button 'Save'
        expect(page).to have_text('Private')
      end

      it 'with private selected cannot see it in the list' do
        check('paste_private')
        click_link_or_button 'Save'
        visit '/pastes'
        expect(page).to have_no_text('Anonymous paste created by')
      end
    end

    context 'without private selected' do
      before do
        visit '/'
        fill_in('paste_code', with: 'John')
        uncheck('paste_private')
        click_link_or_button 'Save'
      end

      it 'creates a new paste' do
        expect(page).to have_no_text('Private')
      end

      it 'can see it in the list' do
        visit '/pastes'
        expect(page).to have_text('Anonymous paste created by')
      end

      it 'cannot destroy their own paste' do
        visit '/pastes'
        click_on 'paste created by'
        expect(page).to have_no_text('Remove')
      end
    end
  end

  context 'when a logged in user creates a new paste' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'test@opensuse.org', nickname: 'testing' } })
      visit '/'
      click_link_or_button 'Log in'
    end

    it 'without entering any content' do
      visit '/'
      click_link_or_button 'Save'
      expect(page).to have_text("Content can't be blank")
    end

    it 'with text file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.txt')
      click_link_or_button 'Save'
      expect(page).to have_text('🌶️ Hot')
    end

    it 'with shell script file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.sh')
      click_link_or_button 'Save'
      expect(page).to have_text('echo "🌶️ Hot"')
    end

    it 'with image file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.png')
      click_link_or_button 'Save'
      expect(page).to have_css('.card-body img')
    end

    it 'with video file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.webm')
      click_link_or_button 'Save'
      expect(page).to have_css('.card-body video')
    end

    it 'with audio file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.flac')
      click_link_or_button 'Save'
      expect(page).to have_css('.card-body audio')
    end

    it 'with document file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.pdf')
      click_link_or_button 'Save'
      expect(page).to have_text('You can only see the full document, if you download it')
    end

    it 'with unrepresentable file content' do
      visit '/'
      attach_file('paste_content', 'spec/fixtures/files/file.tar.xz')
      click_link_or_button 'Save'
      expect(page).to have_css('.card-body a')
    end

    context 'with code content' do
      before do
        visit '/'
        fill_in('paste_code', with: 'John')
      end

      it 'creates a valid paste' do
        click_link_or_button 'Save'
        expect(page).to have_text('John')
      end

      it 'without changing the private state' do
        click_link_or_button 'Save'
        expect(page).to have_text('Private')
      end

      it 'with private selected' do
        check('paste_private')
        click_link_or_button 'Save'
        expect(page).to have_text('Private')
      end

      it 'with private selected can see it in the list' do
        check('paste_private')
        click_link_or_button 'Save'
        visit '/pastes'
        expect(page).to have_text('paste Private created by')
      end
    end

    context 'without private selected' do
      before do
        visit '/'
        fill_in('paste_code', with: 'John')
        uncheck('paste_private')
        click_link_or_button 'Save'
      end

      it 'creates a new paste' do
        expect(page).to have_no_text('Private')
      end

      it 'can see it in the list' do
        visit '/pastes?user=testing'
        expect(page).to have_text('paste created by')
      end

      it 'can destroy their own paste' do
        visit '/pastes'
        click_on 'paste created by'
        click_link_or_button 'Remove'
        expect(page).to have_text('Paste was successfully destroyed.')
      end
    end
  end
end
