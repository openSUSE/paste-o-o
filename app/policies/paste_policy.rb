# frozen_string_literal: true

# Authorizes the Paste objects around the application
class PastePolicy < ApplicationPolicy
  # Scope for the Paste objects, dependant on the logged in user
  class Scope < Scope
    def resolve
      if user&.mod?
        scope.all
      elsif user
        scope.where(user:).or(scope.where(private: false))
      else
        scope.where(private: false)
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def destroy?
    # Pastes may have a nil user, so we have to check for that here
    (!record.user.nil? && record.user == user) || user&.mod?
  end
end
