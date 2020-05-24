class PlansController < ApplicationController
  def new
    @plan = Plan.new
  end

  def create
    binding.pry
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    # customer_token = current_user.customer_token
    # customer = Payjp::Customer.retrieve(customer_token)
    @new_plan = Payjp::Plan.create(
      amount: params[:plan][:amount],
      currency: 'jpy',
      interval: params[:plan][:interval],
      name: params[:plan][:name],
      # trial_days: params[:plan][:trial_days],
      # billing_day: params[:plan][:billing_day],
      metadata: {plan_id: ""}
    )
    @plan = Plan.new(
      amount: params[:plan][:amount],
      interval: params[:plan][:interval],
      name: params[:plan][:name],
      plan_token: @new_plan.id,
      trial_days: params[:plan][:trial_days],
      billing_day: params[:plan][:billing_day]
    )
    if @plan.save
      @new_plan.metadata[:plan_id] = @plan.id
      @new_plan.save
    else
      render :new
    end
  end
end
