# frozen_string_literal: true

# Cleaning up pastes as soon as the remove_at passes
class PastesCleanupJob < ApplicationJob
  queue_as :default

  def perform(paste_id)
    Paste.find_by(id: paste_id)&.destroy
  end
end
