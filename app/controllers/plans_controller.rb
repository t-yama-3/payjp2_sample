class PlansController < ApplicationController
  def new
  end

  def create
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    customer_token = current_user.customer_token
    customer = Payjp::Customer.retrieve(customer_token)
    @new_plan = Payjp::Plan.create(
      amount: 1000,
      currency: 'jpy',
      interval: 'month',
      name: 'test_plan',
      trial_days: 30,
      billing_day: 25,
      metadata: {plan_id: ""}
    )
    plan = Plan.new(plan_token: @new_plan.id)
    if plan.save
      @new_plan.metadata[:plan_id] = plan.id
      @new_plan.save
    else
      render :new
    end
  end
end
