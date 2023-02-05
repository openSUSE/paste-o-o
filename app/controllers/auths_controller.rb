# frozen_string_literal: true

# Implementation of authentication in the application
class AuthsController < ApplicationController
  before_action :set_auth, only: [:destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    @auths = policy_scope(Auth)&.for_user(current_user)
    authorize Auth
  end

  def new
    @auth = authorize Auth.new
  end

  def create
    defaults = {}
    defaults[:user_id] = current_user.id if user_signed_in?
    @auth = authorize Auth.new(auth_params.merge(defaults))

    if @auth.save
      redirect_to auths_url, notice: t(:auth_create)
    else
      render :new, status: :unprocessable_entity
    end
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
    @auth = authorize Auth.find(params[:id])

    redirect_to auths_url, alert: t(:auth_not_found) unless @auth
  end

  def auth_params
    params.require(:auth).permit(:name)
  end
end
