# frozen_string_literal: true

# The term model to delete or moderate posts
class Term < ApplicationRecord
  enum :subject, %w[author title code]
  enum :action, %w[mark_spam remove]
end
