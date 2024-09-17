# frozen_string_literal: true

# The endpoints and pages for pastes
# TODO: Implement authentication from the outside
class PastesController < ApplicationController
  before_action :set_paste, only: %i[show destroy raw]
  before_action :qualify_content, only: :create
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  # Set up activestorage for development
  before_action -> { ActiveStorage::Current.url_options = { host: request.base_url } },
                if: -> { Rails.env.local? }

  def index
    @pastes = if params[:user]
                policy_scope(Paste)&.by_author(User.find_by(username: params[:user]))
              else
                policy_scope(Paste)
              end
  end

  def show
    authorize @paste
  end

  def new
    @paste = authorize Paste.new
  end

  def create
    @paste = authorize Paste.new(paste_params)

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
    authorize @paste

    @paste.destroy

    respond_to do |format|
      format.html { redirect_to pastes_url, notice: t(:paste_destroyed) }
      format.json { head :no_content }
    end
  end

  def raw
    authorize @paste, :show?

    redirect_to @paste.content.attachment.url, allow_other_host: true
  end

  def spam
    authorize Paste.new

    if Paste.where(id: pastes_params[:ids]).update(marked_kind: pastes_params[:marked_kinds], marked_by: current_user)
      redirect_to pastes_url, notice: t(:paste_update)
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_paste
    @paste = Paste.find_by(permalink: params[:paste_permalink] || params[:permalink])

    redirect_to pastes_url, alert: t(:paste_not_found) unless @paste
  end

  def paste_params
    defaults = { marked_kind: @marked_kind }
    defaults[:user_id] = current_user.id if user_signed_in?
    params.require(:paste).permit(:author, :title, :private, :remove_after,
                                  :content, :code, :auth_key).merge(defaults.compact)
  end

  def pastes_params
    params.require(:pastes).permit(:marked_kinds, ids: [])
  end

  def qualify_content
    return unless text_content

    classifier = Rails.application.config.classifier
    @marked_kind = classifier.classify(text_content).downcase
  end

  def text?
    return false if paste_params[:content].blank?

    content_type = paste_params[:content].content_type
    Marcel::Magic.new(content_type).text? || MimeMagic.new(content_type).text?
  end

  def text_content
    return paste_params[:content]&.read&.force_encoding('utf-8') if text?

    paste_params[:code].presence
  end
end
