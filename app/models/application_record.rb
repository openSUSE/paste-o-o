# frozen_string_literal: true

# The model inherited in all other models
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
