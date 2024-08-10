require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:one)
  end

  test "should get index" do
    get transactions_url
    assert_response :success
  end

  test "should get new" do
    get new_transaction_url
    assert_response :success
  end

  test "should create transaction" do
    assert_difference("Transaction.count") do
      post transactions_url, params: { transaction: { amount: @transaction.amount, datetime_of_transaction: @transaction.datetime_of_transaction, fees: @transaction.fees, net_value: @transaction.net_value, operation: @transaction.operation, price: @transaction.price, symbol: @transaction.symbol, total_value: @transaction.total_value, user_id: @transaction.user_id, wallet_id: @transaction.wallet_id } }
    end

    assert_redirected_to transaction_url(Transaction.last)
  end

  test "should show transaction" do
    get transaction_url(@transaction)
    assert_response :success
  end

  test "should get edit" do
    get edit_transaction_url(@transaction)
    assert_response :success
  end

  test "should update transaction" do
    patch transaction_url(@transaction), params: { transaction: { amount: @transaction.amount, datetime_of_transaction: @transaction.datetime_of_transaction, fees: @transaction.fees, net_value: @transaction.net_value, operation: @transaction.operation, price: @transaction.price, symbol: @transaction.symbol, total_value: @transaction.total_value, user_id: @transaction.user_id, wallet_id: @transaction.wallet_id } }
    assert_redirected_to transaction_url(@transaction)
  end

  test "should destroy transaction" do
    assert_difference("Transaction.count", -1) do
      delete transaction_url(@transaction)
    end

    assert_redirected_to transactions_url
  end
end
