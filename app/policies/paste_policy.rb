# frozen_string_literal: true

# Authorizes the Paste objects around the application
class PastePolicy < ApplicationPolicy
  # Scope for the Paste objects, dependant on the logged in user
  class Scope < Scope
    def resolve
      if user&.mod?
        scope.order(created_at: :desc).all
      elsif user
        scope.order(created_at: :desc).where(user:).or(scope.where(private: false, marked_kind: 'ham'))
      else
        scope.none
      end
    end
  end

  def index?
    user.present?
  end

  def show?
    true
  end

  def create?
    !require_login_to_post? || user.present?
  end

  def destroy?
    # Pastes may have a nil user, so we have to check for that here
    (!record.user.nil? && record.user == user) || user&.mod?
  end

  def spam?
    user&.mod?
  end

  private

  # When enabled in site config, posting a paste requires authentication.
  # Defaults to true so the anti-abuse gate is on unless operators opt out.
  def require_login_to_post?
    Rails.configuration.site.fetch(:require_login_to_post, true)
  end
end
