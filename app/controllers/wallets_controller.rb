class WalletsController < ApplicationController

  # index / show / new / edit / create / update / destroy
  before_action :set_wallet, only: [:edit, :update, :show, :destroy]
  before_action :require_user
  before_action :require_same_user, only: [:edit, :update, :destroy, :show]

  # GET /wallets or /wallets.json
  def index
    @wallets = Wallet.all
  end

  def show
    wallet_id = @wallet.id
    @wallet_data = Rails.cache.read("wallet_#{wallet_id}_tokens_data_for_user_#{current_user.id}")

    if @wallet_data.nil?
      Rails.logger.info "Wallet #{wallet_id} tokens data for user #{current_user.id} cache is empty"
    else
      Rails.logger.info "Retrieved wallet #{wallet_id} tokens data for user #{current_user.id} from cache"
    end

    @tokens_data = @wallet_data[:tokens_data]
    @total_balance = @wallet_data[:total_balance]
    @total_deposits = @wallet_data[:total_deposits]
    @total_withdraws = @wallet_data[:total_withdraws]
    @profits_and_losses = @wallet_data[:profits_and_losses]
    @portfolio_distribution = @wallet_data[:portfolio_distribution]
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
      Rails.cache.write("authorisation_for_FetchTokensDataJob_for_session_#{current_session[:id]}_user_#{current_user.id}_wallet_#{@wallet.id}", true)
      Rails.logger.info "Authorisation for FetchTokensDataJob for session #{current_session[:id]}; user #{current_user.id}; wallet #{@wallet.id} approved"
      FetchTokensDataJob.perform_later(current_session[:id], current_user.id, @wallet.id)
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
    Rails.cache.delete("authorisation_for_FetchTokensDataJob_for_session_#{current_session[:id]}_user_#{current_user.id}_wallet_#{@wallet.id}")
    Rails.logger.info "Authorisation for FetchTokensDataJob for session #{current_session[:id]}; user #{current_user.id}; wallet #{@wallet.id} cancelled"
    Rails.cache.delete("wallet_#{@wallet.id}_tokens_data_for_user_#{current_user.id}")
    Rails.logger.info "Wallet #{@wallet.id} tokens data for user #{current_user.id} cache deleted"
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
end
