class CardsController < ApplicationController
  require 'payjp'

  def index
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    if user_signed_in? && current_user.cards.length > 0
      customer = Payjp::Customer.retrieve(current_user.customer_token)
      @cards = customer.cards.all
      @default_card = customer.cards.retrieve(customer.default_card)
    end
  end

  def new
    @month_arr = [{name: '01', id: 1}, {name: '02', id: 2}, {name: '03', id: 3}, {name: '04', id: 4}, {name: '05', id: 5}, {name: '06', id: 6}, {name: '07', id: 7}, {name: '08', id: 8}, {name: '09', id: 9}, {name: '10', id: 10}, {name: '11', id: 11}, {name: '12', id: 12}]
    @year_arr = [{name: '20', id: 2020},{name: '21', id: 2021}, {name: '22', id: 2022}, {name: '23', id: 2023}, {name: '24', id: 2024}, {name: '25', id: 2025}, {name: '26', id: 2026}, {name: '27', id: 2027}, {name: '28', id: 2028}, {name: '29', id: 2029}, {name: '30', id: 2030}]
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
    customer = Payjp::Customer.create(card: token.id, description: 'payjp_test')
    current_user.update(customer_token: customer.id)
    Card.create(user_id: current_user.id, card_token: customer.default_card)
  end

  def create
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    if User.find(current_user.id).customer_token == nil
      customer = Payjp::Customer.create(card: params[:payjp_token], metadata: {card_id: ""}, description: 'payjp_test')
      current_user.update(customer_token: customer.id)  # これのエラーハンドリングはどうするか（後日トランザクションでくくる）
      @new_card = customer.cards.retrieve(customer.default_card)
    else
      customer = Payjp::Customer.retrieve(current_user.customer_token)
      @new_card = customer.cards.create(card: params[:payjp_token], metadata: {card_id: ""})
    end
    card = Card.new(user_id: current_user.id, card_token: @new_card.id)
    if card.save
      @new_card.metadata[:card_id] = card.id
      @new_card.save
    else
      render :new
    end
  end

  def card_show
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]  # PayjpオブジェクトにAPIキー（秘密鍵）を設定
    customer = Payjp::Customer.retrieve(current_user.customer_token)
    @show_card = customer.cards.retrieve(current_user.cards.find(params[:id]).card_token)
  end

  def card_default
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
    customer = Payjp::Customer.retrieve(current_user.customer_token)
    customer.default_card = Card.find(params[:id]).card_token
    customer.save
    redirect_to root_path
  end

  def card_delete
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
    customer = Payjp::Customer.retrieve(current_user.customer_token)
    card = Card.find(params[:id])
    delete_card = customer.cards.retrieve(card.card_token)
    if card.destroy
      delete_card.delete
    else
      flash.now[:alert] = "カードを削除できませんでした。"
    end
    redirect_to root_path
  end
end
