class Budgets::SubheaderComponent < ApplicationComponent
  use_helpers :current_user, :link_to_signin, :link_to_signup, :link_to_verify_account, :can?
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def budget_phase_name(phase)
    phase.name.presence || t("budgets.phase.#{phase.kind}")
  end
end
