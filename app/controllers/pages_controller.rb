class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if logged_in?
  end

  def dashboard
    @user_data = Rails.cache.read('user_data')
    Rails.logger.info "Retrieved user data: #{@user_data}"

    if @user_data.nil?
      Rails.logger.info "Cache is empty"
    else
      Rails.logger.info "Retrieved #{@user_data} from cache"
    end

    @tokens_data = @user_data[:tokens_data]
    @total_balance = @user_data[:total_balance]
    @total_deposits = @user_data[:total_deposits]
    @total_withdraws = @user_data[:total_withdraws]
    @profits_and_losses = @user_data[:profits_and_losses]
    @portfolio_distribution = @user_data[:portfolio_distribution]
  end
end
