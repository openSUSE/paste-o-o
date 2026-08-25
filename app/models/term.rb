# frozen_string_literal: true

# The term model to delete or moderate posts
class Term < ApplicationRecord
  enum :subject, { 'author' => 0, 'title' => 1, 'code' => 2 }
  enum :action, { 'mark_spam' => 0, 'remove' => 1 }

  def matches_regex?(paste_content)
    regex? && Regexp.new(content).match?(paste_content)
  end

  def matches_substring?(paste_content)
    paste_content.include?(content)
  end

  def represent_content
    c = regex? ? '/' : ''
    "#{c}#{content}#{c}"
  end
end
