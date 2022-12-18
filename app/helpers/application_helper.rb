# frozen_string_literal: true

# The primary helper in the applications
module ApplicationHelper
  def avatar(user, size: 24)
    image_tag "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase)}?s=#{size * 2}",
              class: 'rounded', style: "width: #{size}px; height: #{size}px"
  end
end
