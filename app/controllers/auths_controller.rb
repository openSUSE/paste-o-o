# frozen_string_literal: true

# Implementation of authentication in the application
class AuthsController < ApplicationController
  before_action :authenticate
  before_action :set_auth, only: [:destroy]

  def new
    @auth = Auth.new
  end

  def create
    defaults = {}
    defaults[:user_id] = current_user.id if user_signed_in?
    @auth = Auth.new(auth_params.merge(defaults))

    if @auth.save
      redirect_to auths_url, notice: t(:auth_create)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @auths = Auth.for_user(current_user)
  end

  def destroy
    if user_signed_in? && @auth.user == current_user
      @auth.destroy
      redirect_to auths_url, notice: t(:auth_destroyed)
    else
      redirect_to auth_url(@auth), alert: t(:auth_not_destroyed)
    end
  end

  private

  def set_auth
    @auth = Auth.find(params[:id])

    redirect_to auths_url, alert: t(:auth_not_found) unless @auth
  end

  def auth_params
    params.require(:auth).permit(:name)
  end
end
