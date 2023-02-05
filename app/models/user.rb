# frozen_string_literal: true

# The user details as provided by OmniAuth
class User < ApplicationRecord
  has_many :pastes, dependent: :destroy
  has_many :auths, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def mod?
    role == 'mod' || admin?
  end

  def admin?
    role == 'admin'
  end
end
