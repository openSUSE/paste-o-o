# frozen_string_literal: true

# The primary controller in the application
class ApplicationController < ActionController::Base
  protected

  def current_user
    Auth.find_by(id: session[:auth_id])&.user
  end

  def user_signed_in?
    !!current_user
  end

  helper_method :current_user, :user_signed_in?

  private

  def authenticate
    redirect_to root_path, alert: t(:need_login) unless user_signed_in?
  end
end
