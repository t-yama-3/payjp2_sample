class CardsController < ApplicationController
  # protect_from_forgery except: [:create]
  require 'payjp'

  def new
    # card = Card.where(user_id: current_user.id)
  end

  def create
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    # token = Payjp::Token.create({
    #   card: {
    #     number: params[:number],
    #     cvc: params[:cvc],
    #     exp_month: params[:exp_month],
    #     exp_year: params[:exp_year]
    #   }},
    #   {
    #     'X-Payjp-Direct-Token-Generate': 'true'  # (テスト目的のトークン作成)HTTPヘッダーに X-Payjp-Direct-Token-Generate: true を指定
    #   }
    # )
    customer = Payjp::Customer.create(
      card: params[:payjp_token],
      description: 'payjp_test'
    )
    Card.create(
      user_id: current_user.id,
      card_id: customer.default_card,
      customer_id: customer.id
    )
    # binding.pry
  end
end
