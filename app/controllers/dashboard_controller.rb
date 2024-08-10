class DashboardController < ApplicationController
  before_action :set_user_transactions
  before_action :set_tokens_data, only: [:fetch_dashboard_data, :fetch_chart_data]

  def fetch_dashboard_data
    @total_deposits = @user_transactions.where(operation: "DEPOSIT").sum(:net_value)
    @total_withdraws = @user_transactions.where(operation: "WITHDRAW").sum(:net_value).abs
    @profits_and_losses = (@total_withdraws + @total_balance) - @total_deposits

    @tokens_data.delete_if { |token| token[:balance_in_dollars].nil? || token[:balance_in_dollars] <= 0 }
    @tokens_data.sort_by! { |token| token[:balance_in_dollars] }.reverse!

    @portfolio_distribution = {}
    @tokens_data.each do |token|
      if Float(token[:current_price], exception: false) && Float(token[:balance], exception: false)
        token[:portfolio_percentage] = ((token[:balance] * token[:current_price]) / @total_balance) * 100
        @portfolio_distribution[token[:symbol]] = token[:portfolio_percentage]
      else
        token[:portfolio_percentage] = nil
      end
    end

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("dashboard-content", partial: "dashboard/content", locals: { tokens_data: @tokens_data, total_balance: @total_balance, total_deposits: @total_deposits, total_withdraws: @total_withdraws, profits_and_losses: @profits_and_losses }) }
    end
  end

  def fetch_chart_data
    @portfolio_distribution = @tokens_data.map { |token| [token[:symbol], token[:portfolio_percentage]] }

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("chart-container", partial: "dashboard/chart", locals: { portfolio_distribution: @portfolio_distribution }) }
    end
  end

  private

  def set_user_transactions
    @user_transactions = Transaction.where(user_id: current_user.id)
  end

  def set_tokens_data
    @total_balance = 0
    @symbols = @user_transactions.select(:symbol).distinct.pluck(:symbol)

    @tokens_data = @symbols.map do |symbol|
      transactions = @user_transactions.for_symbol(symbol)
      token_current_price = get_current_price(symbol)
      token_average_buy_price = Transaction.average_buy_price(transactions)
      token_average_sell_price = Transaction.average_sell_price(transactions)
      token_balance = Transaction.balance(transactions)

      if Float(token_current_price, exception: false) && Float(token_average_buy_price, exception: false)
        token_current_price = token_current_price
        token_balance_in_dollars = token_balance * token_current_price
        token_potential_profits = token_balance * (token_current_price - token_average_buy_price.to_f)
        @total_balance += token_balance_in_dollars
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
  end

  def get_current_price(symbol)
    service = CoinloreService.new
    current_price = service.get_current_price_by_symbol(symbol)

    return current_price
  end
end
