class TransactionsController < ApplicationController

  # index / show / new / edit / create / update / destroy
  before_action :set_transaction, only: [:edit, :update, :show, :destroy]
  before_action :require_user
  before_action :require_same_user, only: [:edit, :update, :destroy, :show]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.all
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user
    if @transaction.save
      flash[:success] = "Transaction added!"
      redirect_to transaction_path(@transaction)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # POST transactions/import
  def import
    file = params[:file]
    wallet_id = params[:wallet_id]
    user_id = current_user.id

    if file.nil?
      flash[:warning] = "Please select a CSV file to upload."
      render 'upload', status: :unprocessable_entity
      return
    end

    begin
      CSV.foreach(file.path, headers: true) do |row|
        transaction_hash = row.to_hash
        # Assuming the CSV headers match the Transaction model attributes
        Transaction.create!(
          user_id: user_id,
          wallet_id: wallet_id,
          datetime_of_transaction: transaction_hash['datetime_of_transaction'],
          operation: transaction_hash['operation'],
          symbol: transaction_hash['symbol'],
          amount: transaction_hash['amount'],
          price: transaction_hash['price'],
          net_value: transaction_hash['net_value'],
          fees: transaction_hash['fees'],
          total_value: transaction_hash['total_value']
        )
      end
      flash[:success] = "Transactions successfully uploaded."
      redirect_to transactions_path
    rescue => errors
      flash[:danger] = "An error occurred while importing transactions: #{errors}"
      render 'upload', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    if @transaction.update(transaction_params)
      flash[:success] = "Transaction updated!"
      redirect_to transaction_path(@transaction)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # GET transactions/upload
  def upload
    @transaction = Transaction.new
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy!
    flash[:danger] = "Transaction deleted!"
    redirect_to transactions_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:datetime_of_transaction, :operation, :symbol, :amount, :price, :net_value, :fees, :total_value, :user_id, :wallet_id)
    end

    def require_same_user
      if current_user != @transaction.user
        flash[:danger] = "You don't have the rights for this!"
        redirect_to root_path
      end
    end
end
