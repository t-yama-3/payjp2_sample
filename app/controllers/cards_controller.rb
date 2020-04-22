class CardsController < ApplicationController
  # protect_from_forgery except: [:create]
  require 'payjp'

  def new
    # card = Card.where(user_id: current_user.id)
  end

  def create_test  # テストアカウントのみ使用可能
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    token = Payjp::Token.create({
      card: {
        number: params[:number],
        cvc: params[:cvc],
        exp_month: params[:exp_month],
        exp_year: params[:exp_year]
      }},
      {
        'X-Payjp-Direct-Token-Generate': 'true'  # (テスト目的のトークン作成)HTTPヘッダーに X-Payjp-Direct-Token-Generate: true を指定
      }
    )
    customer = Payjp::Customer.create(
      card: token.id,
      description: 'payjp_test'
    )
    Card.create(
      user_id: current_user.id,
      card_id: customer.default_card,
      customer_id: customer.id
    )
  end

  def create
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    if User.find(current_user.id).cards.length == 0
      customer = Payjp::Customer.create(card: params[:payjp_token], description: 'payjp_test')
      card_id = customer.default_card
    else
      customer = Payjp::Customer.retrieve(current_user.cards.first.customer_id)
      card_id = customer.cards.create(card: params[:payjp_token]).id
    end
    card = Card.new(user_id: current_user.id, card_id: card_id, customer_id: customer.id)
    if card.save
    else
      render :new
    end
    # binding.pry
  end

  def show
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    customer = Payjp::Customer.retrieve(current_user.cards.first.customer_id)
    @cards = customer.cards.all()
    # binding.pry
  end
end
