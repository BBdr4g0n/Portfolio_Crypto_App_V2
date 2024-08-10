class TokensController < ApplicationController

  def list_tokens
    service = CoinloreService.new
    list = service.get_tokens_list
    if list
      render json: list
    else
      render json: { error: 'Tokens list not found' }, status: :not_found
    end
  end

  def show_token_infos
    token_symbol = params[:symbol].upcase
    service = CoinloreService.new
    tokens = service.find_tokens_by_symbol(token_symbol)

    if tokens.size == 1
      render json: tokens
    elsif tokens.size > 1
      render json: { warning: 'Multiple coins found', tokens: tokens }, status: :multiple_choices
    else
      render json: { error: 'Coin not found' }, status: :not_found
    end
  end
end
