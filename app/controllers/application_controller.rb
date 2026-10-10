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

  # Render the login prompt (HTML) or a 401 (JSON) with a message describing
  # what the visitor was trying to do. Setting @focus_login tells the navbar to
  # hide its now-redundant login buttons on the prompt page.
  def render_login_required(message)
    @focus_login = true
    @login_message = message

    respond_to do |format|
      format.html { render 'sessions/new', status: :unauthorized }
      format.json { render json: { error: message }, status: :unauthorized }
    end
  end

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

  def user_not_authorized(exception)
    # An anonymous visitor who hit an authentication gate gets a login prompt
    # explaining what they were trying to do. A logged-in user who genuinely
    # lacks permission gets the generic "not authorized" response.
    message = login_required_message(exception)
    return render_login_required(message) if message && !user_signed_in?

    render_not_authorized
  end

  def render_not_authorized
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

  # Message for a paste authentication gate, or nil when the failure is not one
  # we want to prompt logins for (a non-Paste policy, listing pastes, or a
  # logged-in user genuinely lacking permission such as destroying another
  # user's paste).
  def login_required_message(exception)
    return unless exception.policy.is_a?(PastePolicy)

    case exception.query.to_s
    when 'create?', 'new?' then t(:login_required_to_post)
    when 'show?' then t(:login_required_to_view)
    end
  end
end
