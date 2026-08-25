# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Terms' do
  context 'when an anonymous user' do
    it 'tries to access forbidden terms' do
      visit '/terms'
      expect(page).to have_text('You are not authorized to perform this action.')
    end
  end

  context 'when a regular user' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'test@opensuse.org', nickname: 'testing' } })
      visit '/'
      click_link_or_button 'Log in'
    end

    it 'tries to access forbidden terms' do
      visit '/terms'
      expect(page).to have_text('You are not authorized to perform this action.')
    end
  end

  context 'when a moderator user' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'mod@opensuse.org', nickname: 'mod' } })
      visit '/'
      click_link_or_button 'Log in'

      User.last.update(role: 'mod')
    end

    it 'tries to access forbidden terms' do
      visit '/terms'
      expect(page).to have_text('Listing forbidden terms')
    end
  end

  context 'when a moderator user tries to create a term' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'mod@opensuse.org', nickname: 'mod' } })
      visit '/'
      click_link_or_button 'Log in'

      User.last.update(role: 'mod')
    end

    context 'without regex' do
      before do
        visit '/terms'
        click_link 'Create', href: '/terms/new'
        select 'Title', from: 'term_subject'
        fill_in 'term_content', with: 'bad_word'
        select 'Remove', from: 'term_action'
        click_link_or_button 'Save'
      end

      it 'creates the term term', :aggregate_failures do
        expect(page).to have_text('Term was successfully created.')
        expect(page).to have_text('title with content: bad_word')
      end
    end

    context 'with regex' do
      before do
        visit '/terms'
        click_link 'Create', href: '/terms/new'
        select 'Code', from: 'term_subject'
        fill_in 'term_content', with: '^kraa{0,3}ze?y$'
        check 'term_regex'
        select 'Mark spam', from: 'term_action'
        click_link_or_button 'Save'
      end

      it 'creates the term', :aggregate_failures do
        expect(page).to have_text('Term was successfully created.')
        expect(page).to have_text('/^kraa{0,3}ze?y$/')
      end
    end
  end

  context 'when a moderator user tries to create and apply a spam term' do
    let!(:dummy_paste) do
      Paste.create!(
        title: 'this contains a bad_word',
        author: 'Anonymous',
        code: 'some code content'
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'mod@opensuse.org', nickname: 'mod' } })
      visit '/'
      click_link_or_button 'Log in'

      User.last.update(role: 'mod')

      visit '/terms'
      click_link 'Create', href: '/terms/new'
      select 'Title', from: 'term_subject'
      fill_in 'term_content', with: 'bad_word'
      select 'Mark spam', from: 'term_action'
      click_link_or_button 'Save and apply'
    end

    it 'creates the term', :aggregate_failures do
      expect(page).to have_text('Term was successfully created - enforced on 1 existing paste.')
      expect(page).to have_text('title with content: bad_word')
    end

    it 'enforces the term', :aggregate_failures do
      # not checking mark as delete happens quickly after marking as spam
      expect(Paste.exists?(dummy_paste.id)).to be false
    end
  end

  context 'when a moderator user tries to create and apply a remove term' do
    let!(:dummy_paste) do
      Paste.create!(
        title: 'this contains a bad_word',
        author: 'Anonymous',
        code: 'some code content'
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'mod@opensuse.org', nickname: 'mod' } })
      visit '/'
      click_link_or_button 'Log in'

      User.last.update(role: 'mod')

      visit '/terms'
      click_link 'Create', href: '/terms/new'
      select 'Title', from: 'term_subject'
      fill_in 'term_content', with: 'bad_word'
      select 'Remove', from: 'term_action'
      click_link_or_button 'Save and apply'
    end

    it 'creates the term', :aggregate_failures do
      expect(page).to have_text('Term was successfully created - enforced on 1 existing paste.')
      expect(page).to have_text('title with content: bad_word')
    end

    it 'enforces the term', :aggregate_failures do
      dummy_paste.reload
      expect(dummy_paste.marked_by_id).to eq(User.last.id)
      expect(dummy_paste.remove_at).to be_within(1.second).of(5.seconds.from_now)
    end
  end

  context 'when a moderator user tries to remove a term' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:suse, { uid: '12345', info: { email: 'mod@opensuse.org', nickname: 'mod' } })
      visit '/'
      click_link_or_button 'Log in'

      User.last.update(role: 'mod')

      visit '/terms'
      click_link 'Create', href: '/terms/new'
      select 'Title', from: 'term_subject'
      fill_in 'term_content', with: 'bad_word'
      select 'Remove', from: 'term_action'
      click_link_or_button 'Save'
    end

    it 'removes the term', :aggregate_failures do
      click_link_or_button 'Remove'
      expect(page).to have_text('Term was successfully destroyed.')
      expect(page).to have_no_text('bad_word')
    end
  end
end
