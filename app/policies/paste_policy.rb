# frozen_string_literal: true

# Authorizes the Paste objects around the application
class PastePolicy < ApplicationPolicy
  # Scope for the Paste objects, dependant on the logged in user
  class Scope < Scope
    def resolve
      if user&.mod?
        scope.order('created_at DESC').all
      elsif user
        scope.order('created_at DESC').where(user:).or(scope.where(private: false, marked_kind: 'ham'))
      else
        scope.order('created_at DESC').where(private: false, marked_kind: 'ham')
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

  def spam?
    user&.mod?
  end
end
