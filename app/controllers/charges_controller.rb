class ChargesController < ApplicationController
  require 'payjp'
  def index
  end

  def new
    customer = Payjp::Customer.retrieve(current_user.customer_token)
    @cards = customer.cards.all
    @default_card = customer.cards.retrieve(customer.default_card)
  end

  def create
    binding.pry
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    customer_token = current_user.customer_token
    customer = Payjp::Customer.retrieve(customer_token)
    card_token = customer.default_card
    charge = Payjp::Charge.create(
      amount: 1000,
      customer: customer_token,
      card: card_token,
      currency: 'jpy'
    )
  end
end
