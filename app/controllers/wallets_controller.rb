class WalletsController < ApplicationController

  # index / show / new / edit / create / update / destroy
  before_action :set_wallet, only: [:edit, :update, :show, :destroy]
  before_action :require_user
  before_action :require_same_user, only: [:edit, :update, :destroy, :show]

  # GET /wallets or /wallets.json
  def index
    @wallets = Wallet.all
  end

  # GET /wallets/1 or /wallets/1.json
  def show
    @balance = 0
    @wallet_transactions = Transaction.where(user_id: current_user.id, wallet_id: @wallet.id)

    @symbols = @wallet_transactions.select(:symbol).distinct.pluck(:symbol)

    @wallet_tokens_data = @symbols.map do |symbol|
      transactions = @wallet_transactions.for_symbol(symbol)

      token_current_price = get_current_price(symbol)
      token_average_buy_price = Transaction.average_buy_price(transactions)
      token_average_sell_price = Transaction.average_sell_price(transactions)
      token_balance = Transaction.balance(transactions)

      if Float(token_current_price, exception: false) && Float(token_average_buy_price, exception: false)
        token_current_price = token_current_price
        token_balance_in_dollars = token_balance * token_current_price
        token_potential_profits = token_balance * (token_current_price - token_average_buy_price.to_f)
        @balance += token_balance_in_dollars
      else
        token_balance_in_dollars = nil
        token_potential_profits = nil
      end

      {
        symbol: symbol,
        current_price: token_current_price,
        average_buy_price: token_average_buy_price,
        average_sell_price: token_average_sell_price,
        balance: token_balance,
        balance_in_dollars: token_balance_in_dollars,
        potential_profits: token_potential_profits
      }
    end

    @wallet_deposits = @wallet_transactions.where( operation: "DEPOSIT").sum(:net_value)
    @wallet_withdraws = @wallet_transactions.where( operation: "WITHDRAW").sum(:net_value).abs
    @wallet_profits_and_losses = (@wallet_withdraws + @balance) - @wallet_deposits

    @wallet_tokens_data.delete_if { |token| token[:balance_in_dollars] == nil || token[:balance_in_dollars] <= 0 }
    @wallet_tokens_data.sort_by! { |token| token[:balance_in_dollars] }.reverse!

    @wallet_distribution = {}

    @wallet_tokens_data.each do |token|

      if Float(token[:current_price], exception: false) && Float(token[:balance], exception: false)
        token[:portfolio_percentage] = ((token[:balance] * token[:current_price]) / @balance) * 100
        @wallet_distribution[token[:symbol]] = token[:portfolio_percentage]
      else
        token[:portfolio_percentage] = nil
      end
    end
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
  end

  # GET /wallets/1/edit
  def edit
  end

  # POST /wallets or /wallets.json
  def create
    @wallet = Wallet.new(wallet_params)
    @wallet.user = current_user
    if @wallet.save
      flash[:success] = "Wallet created!"
      redirect_to wallet_path(@wallet)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /wallets/1 or /wallets/1.json
  def update
    if @wallet.update(wallet_params)
      flash[:success] = "Wallet updated!"
      redirect_to wallet_path(@wallet)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /wallets/1 or /wallets/1.json
  def destroy
    @wallet.destroy!
    flash[:danger] = "Wallet deleted!"
    redirect_to wallets_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wallet_params
      params.require(:wallet).permit(:name, :user_id)
    end

    def require_same_user
      if current_user != @wallet.user
        flash[:danger] = "You don't have the rights for this!"
        redirect_to root_path
      end
    end

    def get_current_price(symbol)
      service = CoinloreService.new
      current_price = service.get_current_price_by_symbol(symbol)

      return current_price
    end
end
