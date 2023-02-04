# frozen_string_literal: true

# The omniauth handling
class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    auth = Auth.from_omniauth(request.env['omniauth.auth'])
    if auth.user.valid?
      session[:auth_id] = auth.id
      redirect_to root_path, notice: t(:login_success)
    else
      redirect_to root_path, alert: t(:login_failure)
    end
  end

  def destroy
    session[:auth_id] = nil
    redirect_to root_path, notice: t(:logout_success)
  end
end
