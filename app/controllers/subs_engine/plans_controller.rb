# frozen_string_literal: true

module SubsEngine
  class PlansController < ApplicationController
    before_action :set_plan, only: [:show, :edit, :update, :deactivate]

    def index
      @plans = plan_repository.find_active
    end

    def show; end

    def new
      @plan = Plan.new
      authorize @plan
    end

    def edit
      authorize @plan
    end

    def create
      authorize Plan.new

      case CreatePlan.new.call(plan_params)
      in Success(plan)
        redirect_to plan, notice: t('subs_engine.plans.created')
      in Failure[:validation_failed, plan]
        @plan = plan
        render :new, status: :unprocessable_content
      end
    end

    def update
      authorize @plan

      case UpdatePlan.new.call(@plan, plan_params)
      in Success(plan)
        redirect_to plan, notice: t('subs_engine.plans.updated')
      in Failure[:validation_failed, plan]
        @plan = plan
        render :edit, status: :unprocessable_content
      end
    end

    def deactivate
      authorize @plan

      case DeactivatePlan.new.call(@plan)
      in Success
        redirect_to plans_path, notice: t('subs_engine.plans.deactivated')
      in Failure[:already_inactive, *]
        redirect_to plans_path, alert: t('subs_engine.plans.already_inactive')
      end
    end

    private

    def set_plan
      @plan = plan_repository.find_by_id(params[:id]) || raise(ActiveRecord::RecordNotFound)
    end

    def plan_params
      params.expect(plan: [:name, :slug, :interval, :amount_cents, :currency, :active])
    end

    def plan_repository
      @plan_repository ||= PlanRepository.new
    end
  end
end
