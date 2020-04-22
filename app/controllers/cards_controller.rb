class CardsController < ApplicationController
  require 'payjp'

  def index
    if user_signed_in? && current_user.cards.length > 0
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
      customer = Payjp::Customer.retrieve(current_user.cards.first.customer_token)
      @cards = customer.cards.all
      @default_card = customer.cards.retrieve(customer.default_card)
    end
  end

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
      card_token: customer.default_card,
      customer_token: customer.id
    )
  end

  def create
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    if User.find(current_user.id).cards.length == 0
      customer = Payjp::Customer.create(card: params[:payjp_token], metadata: {card_id: ""}, description: 'payjp_test')
      @new_card = customer.cards.retrieve(customer.default_card)
    else
      customer = Payjp::Customer.retrieve(current_user.cards.first.customer_token)
      @new_card = customer.cards.create(card: params[:payjp_token], metadata: {card_id: ""})
    end
    card = Card.new(user_id: current_user.id, card_token: @new_card.id, customer_token: customer.id)
    if card.save
      @new_card.metadata[:card_id] = card.id
      @new_card.save
    else
      render :new
    end
    # binding.pry
  end

  def show
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    customer = Payjp::Customer.retrieve(current_user.cards.first.customer_token)
    @cards = customer.cards.all
    @default_card = customer.cards.retrieve(customer.default_card)
    # binding.pry
  end

  def card_delete
    redirect_to root_path
  end
end
