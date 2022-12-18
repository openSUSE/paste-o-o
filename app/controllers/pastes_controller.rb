# frozen_string_literal: true

# The endpoints and pages for pastes
# TODO: Implement authentication from the outside
class PastesController < ApplicationController
  before_action :set_paste, only: %i[show destroy]
  before_action :own_paste, only: %i[destroy]
  # Set up activestorage for development
  before_action -> { ActiveStorage::Current.url_options = { host: request.base_url } },
                if: -> { Rails.env.development? || Rails.env.test? }

  def index
    @pastes = if params[:user]
                Paste.for_user(current_user).by_author(User.find_by(username: params[:user]))
              else
                Paste.for_user(current_user)
              end
  end

  def show; end

  def new
    @paste = Paste.new
  end

  def create
    @paste = Paste.new(paste_params)

    respond_to do |format|
      if @paste.save
        format.html { redirect_to paste_url(@paste), notice: t(:paste_create) }
        format.json { render :show, status: :created, location: @paste }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @paste.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @paste.destroy

    respond_to do |format|
      format.html { redirect_to pastes_url, notice: t(:paste_destroyed) }
      format.json { head :no_content }
    end
  end

  private

  def set_paste
    @paste = Paste.find_by(permalink: params[:permalink])

    redirect_to pastes_url, alert: t(:paste_not_found) unless @paste
  end

  def own_paste
    redirect_to pastes_url, alert: t(:paste_not_destroyed) unless user_signed_in? && @paste.user == current_user
  end

  def paste_params
    defaults = {}
    defaults[:user_id] = current_user.id if user_signed_in?
    params.require(:paste).permit(:author, :title, :private, :remove_after, :content, :code, :auth_key).merge(defaults)
  end
end
