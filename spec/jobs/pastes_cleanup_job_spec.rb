# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PastesCleanupJob do
  describe '#perform_later' do
    let(:time) { rand(3.months).seconds.from_now }
    let(:paste) do
      Paste.create(title: 'title', author: 'author', code: 'the contents of the paste', remove_at: time)
    end

    before do
      ActiveJob::Base.queue_adapter = :test
      freeze_time
    end

    it 'enqueues the paste removal' do
      expect { paste }.to have_enqueued_job(described_class).on_queue('default')
    end

    it 'removes the paste' do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
      expect { paste }.to perform_job(described_class).at(time)
    end
  end
end
