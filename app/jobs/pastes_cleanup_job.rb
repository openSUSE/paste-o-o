# frozen_string_literal: true

# Cleaning up pastes as soon as the remove_at passes
class PastesCleanupJob < ApplicationJob
  queue_as :default

  def perform(paste)
    paste.destroy
  end
end
