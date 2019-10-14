class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :accounts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :budgets, through: :categories, dependent: :destroy
  has_many :transactions, through: :accounts, dependent: :destroy
  after_save :create_categories
  validates :first_name, :last_name, presence: true

  def balance_on_date(date)
    sql_query = "datetime <= ?"
    transactions.where(sql_query, date).sum(:amount_cents)
  end

  def balance_today
    balance_on_date(Date.today)
  end

  def balance_for_month(month_year)
    month_as_date = Date.parse("1 #{month_year}")
    end_of_month = (month_as_date >> 1) - month_as_date.day
    array_of_month = (month_as_date..end_of_month).to_a
    array_of_balances = []
    array_of_month.each do |date|
      array_of_balances << balance_on_date(date) / 100
    end
    array_of_balances
  end

  def available_balance(month_year)
    income = income_to_date(month_year).sum(:amount_cents)
    budg = budgets_to_date(month_year).sum(:amount_cents)
    (income - budg)
  end

  def budgets_to_date(month_year)
    sql_query = " \
        extract(month from month_from) <= ? \
        AND extract(year from month_from) <= ? \
      "
    month_as_date = Date.parse("1 #{month_year}")
    budgets.where(sql_query, month_as_date.month, month_as_date.year)
  end

  def budgets_for_month(month_year)
    sql_query = " \
        extract(month from month_from) = ? \
        AND extract(year from month_from) = ? \
      "
    month_as_date = Date.parse("1 #{month_year}")
    budgets.where(sql_query, month_as_date.month, month_as_date.year)
  end

  def income_to_date(month_year)
    sql_query = " \
        extract(month from datetime) <= ? \
        AND extract(year from datetime) <= ? \
      "
    date = Date.parse("1 #{month_year}")
    income_trans = transactions.where(category: income_cat)
    income_trans.where(sql_query, date.month, date.year)
  end

   def income_for_month(month_year)
    sql_query = " \
        extract(month from datetime) = ? \
        AND extract(year from datetime) = ? \
      "
    date = Date.parse("1 #{month_year}")
    income_trans = transactions.where(category: income_cat)
    income_trans.where(sql_query, date.month, date.year)
  end

  def income_cat
    categories.find_by(name: 'Income')
  end

  def no_cat
    categories.find_by(name: 'No Category')
  end

  def categorize_all
    no_category = no_cat
    transactions.where(approved_at: nil).each do |transaction|
      # p trans
      transaction.auto_categorize
    end
    "Done"
  end

  private

  def create_categories
    if categories.count.zero?
      Category.create(user: self, name: 'Groceries', icon: (Icon.find_by(name: 'Groceries')), color: '#55efc4')
      Category.create(user: self, name: 'Food & Drinks', icon: (Icon.find_by(name: 'Food & Drinks')), color: '#00b894')
      Category.create(user: self, name: 'Clothing', icon: (Icon.find_by(name: 'Clothing')), color: '#ffeaa7')
      Category.create(user: self, name: 'Home & Interior', icon: (Icon.find_by(name: 'Home & Interior')), color: '#fdcb6e')
      Category.create(user: self, name: 'Sports & Activities', icon: (Icon.find_by(name: 'Sports & Activities')), color: '#fd79a8')
      Category.create(user: self, name: 'Hygiene & Beauty', icon: (Icon.find_by(name: 'Hygiene & Beauty')), color: '#FDA7DF')
      Category.create(user: self, name: 'Gadgets', icon: (Icon.find_by(name: 'Gadgets')), color: '#fab1a0')
      Category.create(user: self, name: 'Entertainment', icon: (Icon.find_by(name: 'Entertainment')), color: '#00cec9')
      Category.create(user: self, name: 'Bills & Fees', icon: (Icon.find_by(name: 'Bills & Fees')), color: '#81ecec')
      Category.create(user: self, name: 'Rent & Loans', icon: (Icon.find_by(name: 'Rent & Loans')), color: '#74b9ff')
      Category.create(user: self, name: 'Transport', icon: (Icon.find_by(name: 'Transport')), color: '#0984e3')
      Category.create(user: self, name: 'Gifts', icon: (Icon.find_by(name: 'Gifts')), color: '#ff7675')
      Category.create(user: self, name: 'Savings', icon: (Icon.find_by(name: 'Savings')), color: '#e84393')
      Category.create(user: self, name: 'Travel', icon: (Icon.find_by(name: 'Travel')), color: '#a29bfe')
      Category.create(user: self, name: 'Income', icon: (Icon.find_by(name: 'Income')), color: '#6c5ce7')
      Category.create(user: self, name: 'No Category', icon: (Icon.find_by(name: 'No Category')), color: 'transparent')
    end
  end
end
