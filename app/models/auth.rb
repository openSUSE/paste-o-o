# frozen_string_literal: true

# The keys for users
class Auth < ApplicationRecord
  belongs_to :user
  has_secure_token :key, length: 36

  scope :for_user, ->(current_user) { where(user: current_user) }

  def self.from_omniauth(response)
    info = response.info
    username = info['nickname'] || info['name']
    user = User.find_or_create_by!(username:) do |u|
      u.email = info['email']
    end
    find_or_create_by!(uid: response['uid'], name: response['provider'], user:)
  end
end
