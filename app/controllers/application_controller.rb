# frozen_string_literal: true

# The primary controller in the application
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def current_user
    @current_user ||= user_from_session || user_from_api_key
  end

  def user_signed_in?
    !!current_user
  end

  helper_method :current_user, :user_signed_in?

  private

  def user_from_session
    Auth.find_by(id: session[:auth_id])&.user
  end

  # Allow programmatic clients (curl, the old API) to authenticate by passing
  # an API key rather than holding a browser session.
  def user_from_api_key
    return unless (key = api_key)

    user = Auth.find_by(key:)&.user
    user if user&.valid?
  end

  def api_key
    from_header = request.authorization.to_s[/\ABearer (.+)\z/, 1]
    from_header.presence ||
      params[:auth_key].presence ||
      params[:api_key].presence ||
      params.dig(:paste, :auth_key).presence
  end

  def user_not_authorized
    respond_to do |format|
      format.html do
        flash[:alert] = t(:not_authorized)
        redirect_back_or_to(root_path)
      end

      format.json do
        render json: { error: t(:not_authorized) }, status: :forbidden
      end
    end
  end
end
