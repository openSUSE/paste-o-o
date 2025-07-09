class Term < ApplicationRecord
  enum :subject, %w[author title code]
end
