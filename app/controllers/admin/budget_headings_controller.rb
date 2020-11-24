class Admin::BudgetHeadingsController < Admin::BaseController
  include Translatable
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget
  before_action :load_group
  before_action :load_headings, only: [:index, :create]
  before_action :load_heading, except: [:new, :index, :create]
  before_action :set_budget_mode, only: [:index, :create, :update]

  def index
    @heading = @group.headings.new
  end

  def new
    @heading = @group.headings.new
  end

  def edit
  end

  def create
    @heading = @group.headings.new(budget_heading_params)
    if @heading.save
      notice = t("admin.budget_headings.create.notice")
      if @mode == "single"
        redirect_to admin_budget_budget_phases_path(@budget, url_params)
      elsif @mode == "multiple"
        redirect_to admin_budget_group_headings_path(@budget, @group, url_params), notice: notice
      else
        redirect_to admin_budget_path(@budget), notice: notice
      end
    else
      render :new
    end
  end

  def update
    if @heading.update(budget_heading_params)
      redirect_to admin_budget_path(@budget), notice: t("admin.budget_headings.update.notice")
    else
      render :edit
    end
  end

  def destroy
    if @heading.can_be_deleted?
      @heading.destroy!
      redirect_to admin_budget_path(@budget), notice: t("admin.budget_headings.destroy.success_notice")
    else
      redirect_to admin_budget_path(@budget), alert: t("admin.budget_headings.destroy.unable_notice")
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:group_id]
    end

    def load_headings
      @headings = @group.headings.order(:id)
    end

    def load_heading
      @heading = @group.headings.find_by_slug_or_id! params[:id]
    end

    def url_params
      @mode.present? ? { mode: @mode } : {}
    end

    def budget_heading_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude, :max_ballot_lines]
      params.require(:budget_heading).permit(*valid_attributes, translation_params(Budget::Heading))
    end

    def budget_mode_params
      params.require(:budget).permit(:mode) if params.key?(:budget)
    end

    def set_budget_mode
      if params[:mode] || budget_mode_params.present?
        @mode = params[:mode] || budget_mode_params[:mode]
      end
    end
end
