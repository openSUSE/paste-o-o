# frozen_string_literal: true

# The page for setting up terms
class TermsController < ApplicationController
  before_action :set_term, only: :destroy
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Term.new
    @terms = policy_scope(Term)
  end

  def new
    @term = authorize Term.new
  end

  def create
    @term = authorize Term.new(term_params)

    if @term.save
      redirect_to terms_url, notice: t(:term_create)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @term

    @term.destroy

    redirect_to terms_url, notice: t(:term_destroyed)
  end

  private

  def set_term
    @term = Term.find(params[:term_id] || params[:id])

    redirect_to terms_url, alert: t(:term_not_found) unless @term
  end

  def term_params
    params.require(:term).permit(:subject, :content)
  end
end
