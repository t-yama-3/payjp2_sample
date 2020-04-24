class PlansController < ApplicationController
  def new
  end

  def create
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    customer_token = current_user.customer_token
    customer = Payjp::Customer.retrieve(customer_token)
    @new_plan = Payjp::Plan.create(
      amount: params[:amount],
      currency: 'jpy',
      interval: params[:interval],
      name: params[:name],
      trial_days: params[:trial_days],
      billing_day: params[:billing_day],
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
