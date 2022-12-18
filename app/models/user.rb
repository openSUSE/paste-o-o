# frozen_string_literal: true

class User < ApplicationRecord
  has_many :pastes, dependent: :destroy
  has_many :auths, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
