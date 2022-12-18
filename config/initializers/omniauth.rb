# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  if (oidc = Rails.configuration.site.dig(:authentication, :openid_connect))
    provider :openid_connect, oidc
  end
end
