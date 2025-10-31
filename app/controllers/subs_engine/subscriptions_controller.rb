# frozen_string_literal: true

module SubsEngine
  class SubscriptionsController < ApplicationController
    before_action :set_subscription, only: [:show, :update, :destroy]

    def show
      authorize @subscription
      @available_plans = plan_repository.find_active.where.not(id: @subscription.plan_id)
    end

    def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      customer = customer_repository.find_by_external_id(pundit_user.id.to_s).value_or do
        return head :not_found
      end

      plan = plan_repository.find_by_id(params[:plan_id]).value_or do
        return head :not_found
      end

      case SubscribeCustomer.new.call(customer: customer, plan: plan)
      in Success(subscription)
        redirect_to subscription, notice: t('subs_engine.subscriptions.created')
      in Failure[:plan_inactive, *]
        redirect_to plans_path, alert: t('subs_engine.subscriptions.plan_inactive')
      in Failure[:already_subscribed, *]
        redirect_to plans_path, alert: t('subs_engine.subscriptions.already_subscribed')
      in Failure[:stripe_error, message]
        redirect_to plans_path, alert: t('subs_engine.subscriptions.stripe_error')
      end
    end

    def update # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      authorize @subscription

      new_plan = plan_repository.find_by_id(params[:subscription][:plan_id]).value_or do
        return redirect_to @subscription, alert: t('subs_engine.subscriptions.plan_inactive')
      end

      case ChangePlan.new.call(subscription: @subscription, new_plan: new_plan)
      in Success(subscription)
        redirect_to subscription, notice: t('subs_engine.subscriptions.plan_changed')
      in Failure[:same_plan, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.same_plan')
      in Failure[:plan_inactive, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.plan_inactive')
      in Failure[:subscription_not_active, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.subscription_not_active')
      in Failure[:stripe_error, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.stripe_error')
      end
    end

    def destroy
      authorize @subscription

      case CancelSubscription.new.call(@subscription)
      in Success(subscription)
        redirect_to subscription, notice: t('subs_engine.subscriptions.canceled')
      in Failure[:already_canceled, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.already_canceled')
      in Failure[:transition_failed, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.cancel_failed')
      in Failure[:stripe_error, *]
        redirect_to @subscription, alert: t('subs_engine.subscriptions.stripe_error')
      end
    end

    private

    def set_subscription
      @subscription = subscription_repository.find_by_id(params[:id]).value_or do
        raise ActiveRecord::RecordNotFound
      end
    end

    def customer_repository
      @customer_repository ||= CustomerRepository.new
    end

    def plan_repository
      @plan_repository ||= PlanRepository.new
    end

    def subscription_repository
      @subscription_repository ||= SubscriptionRepository.new
    end
  end
end
