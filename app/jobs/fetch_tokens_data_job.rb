class FetchTokensDataJob < ApplicationJob
  queue_as :default

  def perform(session_id, user_id, wallet_id = nil)

    if wallet_id && Rails.cache.read("authorisation_for_FetchTokensDataJob_for_session_#{session_id}_user_#{user_id}_wallet_#{wallet_id}").nil?
      Rails.logger.info "FetchTokensDataJob for session #{session_id}; user #{user_id}; wallet #{wallet_id} deleted from Sidekiq"
      return
    elsif Rails.cache.read("authorisation_for_FetchTokensDataJob_for_session_#{session_id}_user_#{user_id}").nil?
      Rails.logger.info "FetchTokensDataJob for session #{session_id}; user #{user_id} deleted from Sidekiq"
      return
    end

    if wallet_id
      Rails.logger.info "Performing FetchTokensDataJob for session #{session_id}; user #{user_id}; wallet #{wallet_id}"
      @wallet_data = get_tokens_data(user_id, *wallet_id)

      if @wallet_data.nil?
        Rails.logger.info "An issue occured during FetchTokensDataJob for session #{session_id}; user #{user_id}; wallet #{wallet_id}"
        Rails.logger.info "FetchTokensDataJob for session #{session_id}; user #{user_id}; wallet #{wallet_id} deleted from Sidekiq"
        return
      else
        Rails.cache.write("wallet_#{wallet_id}_tokens_data_for_user_#{user_id}", @wallet_data)
        Rails.logger.info "Data for session #{session_id}; user #{user_id}; wallet #{wallet_id} cached"
        FetchTokensDataJob.set(wait: 1.minute).perform_later(session_id, user_id, *wallet_id)
        Rails.logger.info "FetchTokensDataJob for session #{session_id}; user #{user_id}; wallet #{wallet_id} added to Sidekiq"
      end

    else
      Rails.logger.info "Performing FetchTokensDataJob for session #{session_id}; user #{user_id}"
      @dashboard_data = get_tokens_data(user_id)

      if @dashboard_data.nil?
        Rails.logger.info "An issue occured during FetchTokensDataJob for session #{session_id}; user #{user_id}"
        Rails.logger.info "FetchTokensDataJob for session #{session_id}; user #{user_id} deleted from Sidekiq"
        return
      else
        Rails.cache.write("dashboard_tokens_data_for_user_#{user_id}", @dashboard_data)
        Rails.logger.info "Data for session #{session_id}; user #{user_id} cached"
        FetchTokensDataJob.set(wait: 1.minute).perform_later(session_id, user_id)
        Rails.logger.info "FetchTokensDataJob for session #{session_id}; user #{user_id} added to Sidekiq"
      end
    end
  end

  def get_tokens_data(user_id, *wallet_id)
    Rails.logger.info "Fetching tokens data for user_id: #{user_id}, wallet_id: #{wallet_id}"
    @total_balance = 0

    if wallet_id.empty?
      @transactions = Transaction.where(user_id: user_id)
    else
      @transactions = Transaction.where(user_id: user_id, wallet_id: wallet_id)
    end

    @symbols = @transactions.select(:symbol).distinct.pluck(:symbol)

    @tokens_data = @symbols.map do |symbol|
    transactions = @transactions.for_symbol(symbol)

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

    @total_deposits = @transactions.where( operation: "DEPOSIT").sum(:net_value)
    @total_withdraws = @transactions.where( operation: "WITHDRAW").sum(:net_value).abs
    @profits_and_losses = (@total_withdraws + @total_balance) - @total_deposits

    @tokens_data.delete_if { |token| token[:balance_in_dollars] == nil || token[:balance_in_dollars] <= 0 }
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

    @data = {
      tokens_data: @tokens_data,
      total_balance: @total_balance,
      total_deposits: @total_deposits,
      total_withdraws: @total_withdraws,
      profits_and_losses: @profits_and_losses,
      portfolio_distribution: @portfolio_distribution
    }

    #Rails.logger.info "/nData: #{@data}"
    return @data
  end

  private

    def get_current_price(symbol)
      service = CoinloreService.new
      current_price = service.get_current_price_by_symbol(symbol)

      return current_price
    end

    def get_portfolio_distribution(tokens_data)
      #TODO
    end
  end
