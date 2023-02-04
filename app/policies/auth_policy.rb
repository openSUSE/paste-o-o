# frozen_string_literal: true

# Authorizes Auth objects around the application
class AuthPolicy < ApplicationPolicy
  # Scope for the Auth objects, dependant on the logged in user
  class Scope < Scope
    def resolve
      if user&.mod?
        scope.all
      elsif user
        scope.where(user:)
      end
    end
  end

  def index?
    !!user
  end

  def create?
    !!user
  end

  def destroy?
    record.user == user || user.mod?
  end
end
