class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if logged_in?
  end

  def dashboard
    @dashboard_data = Rails.cache.read("dashboard_tokens_data_for_user_#{current_user.id}")

    if @dashboard_data.nil?
      Rails.logger.info "Dashboard tokens data for user #{current_user.id} cache is empty"
    else
      Rails.logger.info "Retrieved dashboard tokens data for user #{current_user.id} from cache"
    end

    @tokens_data = @dashboard_data[:tokens_data]
    @total_balance = @dashboard_data[:total_balance]
    @total_deposits = @dashboard_data[:total_deposits]
    @total_withdraws = @dashboard_data[:total_withdraws]
    @profits_and_losses = @dashboard_data[:profits_and_losses]
    @portfolio_distribution = @dashboard_data[:portfolio_distribution]
  end
end
