# frozen_string_literal: true

# Authorizes the Term objects around the application
class TermPolicy < ApplicationPolicy
  # Scope for the Term objects
  class Scope < Scope
    def resolve
      if user&.mod?
        scope.order('created_at DESC').all
      else
        []
      end
    end
  end

  def index?
    user&.mod?
  end

  def create?
    user&.mod?
  end

  def destroy?
    user&.mod?
  end
end
