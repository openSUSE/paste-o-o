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

  def enforce_term(term)
    count = 0
    Paste.where.not(marked_kind: 'spam').find_each do |paste|
      count += 1 if paste.enforce_term!(term, current_user.id)
    end

    count
  end

  def create
    @term = authorize Term.new(term_params)

    if @term.save
      if params[:save_and_apply].present?
        redirect_to terms_url, notice: t(:term_created_applied, count: enforce_term(@term))
      else
        redirect_to terms_url, notice: t(:term_created)
      end
    else
      render :new, status: :unprocessable_content
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
    params.expect(term: %i[action content regex subject])
  end
end
