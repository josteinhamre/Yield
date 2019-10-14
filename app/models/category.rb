class Category < ApplicationRecord
  belongs_to :user
  belongs_to :icon
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  validates :name, :color, presence: true

  def self.income

  end

  def balance(month_year)
    trans = transactions_to_date(month_year).sum(:amount_cents)
    budg = budgets_to_date(month_year).sum(:amount_cents)
    budg + trans
  end

  def budgets_to_date(month_year)
    sql_query = " \
        extract(month from month_from) <= ? \
        AND extract(year from month_from) <= ? \
      "
    month_as_date = Date.parse("1 #{month_year}")
    budgets.where(sql_query, month_as_date.month, month_as_date.year)
  end

  def transactions_to_date(month_year)
    sql_query = " \
        extract(month from datetime) <= ? \
        AND extract(year from datetime) <= ? \
      "
    date = Date.parse("1 #{month_year}")
    transactions.where(sql_query, date.month, date.year)
  end

  def income?
    name == 'Income'
  end

  def no_cat?
    name == 'No Category'
  end
end
