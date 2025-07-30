class Term < ApplicationRecord
  enum :subject, %w[author title code]
  enum :action, %w[mark_spam remove]
end
