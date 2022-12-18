# frozen_string_literal: true

json.extract! paste, :id, :author, :user_id, :title, :private, :remove_at, :content, :created_at, :updated_at
json.url paste_url(paste, format: :json)
json.content url_for(paste.content)
