require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  setup do
    @transaction = transactions(:one)
  end

  test "visiting the index" do
    visit transactions_url
    assert_selector "h1", text: "Transactions"
  end

  test "should create transaction" do
    visit transactions_url
    click_on "New transaction"

    fill_in "Amount", with: @transaction.amount
    fill_in "Datetime of transaction", with: @transaction.datetime_of_transaction
    fill_in "Fees", with: @transaction.fees
    fill_in "Net value", with: @transaction.net_value
    fill_in "Operation", with: @transaction.operation
    fill_in "Price", with: @transaction.price
    fill_in "Symbol", with: @transaction.symbol
    fill_in "Total value", with: @transaction.total_value
    fill_in "User", with: @transaction.user_id
    fill_in "Wallet", with: @transaction.wallet_id
    click_on "Create Transaction"

    assert_text "Transaction was successfully created"
    click_on "Back"
  end

  test "should update Transaction" do
    visit transaction_url(@transaction)
    click_on "Edit this transaction", match: :first

    fill_in "Amount", with: @transaction.amount
    fill_in "Datetime of transaction", with: @transaction.datetime_of_transaction
    fill_in "Fees", with: @transaction.fees
    fill_in "Net value", with: @transaction.net_value
    fill_in "Operation", with: @transaction.operation
    fill_in "Price", with: @transaction.price
    fill_in "Symbol", with: @transaction.symbol
    fill_in "Total value", with: @transaction.total_value
    fill_in "User", with: @transaction.user_id
    fill_in "Wallet", with: @transaction.wallet_id
    click_on "Update Transaction"

    assert_text "Transaction was successfully updated"
    click_on "Back"
  end

  test "should destroy Transaction" do
    visit transaction_url(@transaction)
    click_on "Destroy this transaction", match: :first

    assert_text "Transaction was successfully destroyed"
  end
end
