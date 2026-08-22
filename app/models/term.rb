# frozen_string_literal: true

# The term model to delete or moderate posts
class Term < ApplicationRecord
  enum :subject, { 'author' => 0, 'title' => 1, 'code' => 2 }
  enum :action, { 'mark_spam' => 0, 'remove' => 1 }
end
