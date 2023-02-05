# frozen_string_literal: true

# The primary controller in the application
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def current_user
    Auth.find_by(id: session[:auth_id])&.user
  end

  def user_signed_in?
    !!current_user
  end

  helper_method :current_user, :user_signed_in?

  private

  def user_not_authorized
    flash[:alert] = t(:not_authorized)
    redirect_back(fallback_location: root_path)
  end
end
