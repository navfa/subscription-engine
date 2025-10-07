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
      @plan = Plan.new(plan_params)
      authorize @plan

      if @plan.save
        redirect_to @plan, notice: t('subs_engine.plans.created')
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      authorize @plan

      if @plan.update(plan_params)
        redirect_to @plan, notice: t('subs_engine.plans.updated')
      else
        render :edit, status: :unprocessable_content
      end
    end

    def deactivate
      authorize @plan
      @plan.update!(active: false)
      redirect_to plans_path, notice: t('subs_engine.plans.deactivated')
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
