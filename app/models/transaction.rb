class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet

  before_validation :set_fees_and_total_value
  before_save { self.symbol.upcase! }

  validates :user_id, presence: true
  validates :wallet_id, presence: true
  validates :datetime_of_transaction, presence: true
  validates :operation, presence: true,
                        length: { minimum: 2, maximum: 10 }
  validates :symbol, presence: true,
                    length: { minimum: 2, maximum: 10 }
  validates :amount, presence: true,
                    numericality: true
  validates :price, presence: true,
                    numericality: true
  validates :net_value, presence: true,
                        numericality: true
  validates :fees, presence: true,
                        numericality: true
  validates :total_value, presence: true,
                          numericality: true

  scope :for_symbol, ->(symbol) { where(symbol: symbol) }
  scope :buys, -> { where(operation: 'BUY') }
  scope :sells, -> { where(operation: 'SELL') }

  def self.average_buy_price(transactions)
    buy_transactions = transactions.buys
    return nil if buy_transactions.empty?

    average_buy_price = buy_transactions.average(:price)
    return average_buy_price
  end


  def self.average_sell_price(transactions)
    sell_transactions = transactions.sells
    return nil if sell_transactions.empty?

    average_sell_price = sell_transactions.average(:price)
    return average_sell_price
  end

  def self.balance(transactions)
    balance = transactions.sum(:amount)
    return balance
  end

  private

    def set_fees_and_total_value
      if !self.fees.present?
        self.fees = 0
        if !self.total_value.present?
          self.total_value = self.net_value
        end
      end
    end
end
