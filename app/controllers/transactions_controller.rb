class TransactionsController < ApplicationController
  def confirm
    @transaction = Transaction.find(params[:id])
    @transaction.approved_at = Time.now
    @transaction.save
  end

  def index
    get_transactions
  end

  def inbox
    unsorted = User.first.transactions.where(approved_at: nil)
    unsorted = User.first.transactions.where(approved_at: nil)
    @transactions = (unsorted.sort_by &:datetime).reverse
  end

  def set_category
    @transaction = Transaction.find(params[:id])
    @transaction.category = Category.find(params[:category_id])
    @transaction.save
  end

  def prev_month
    @selected_month = (Date.parse("1 #{@selected_month}") << 1).strftime("%B %y")
    session[:selected_month] = @selected_month
    get_budgets
    get_transactions
  end

  def next_month
    @selected_month = (Date.parse("1 #{@selected_month}") >> 1).strftime("%B %y")
    session[:selected_month] = @selected_month
    get_budgets
    get_transactions
  end

  def create
    # raise
    Transaction.import_dnb(params['transactions']['file'], User.first)
    Transaction.import_dnb(params['transactions']['file'], User.first)
     # flash[:notice] = "Countries uploaded successfully"
    redirect_to inbox_path
  end

  def categorize
    User.first.categorize_all
    User.first.categorize_all
    redirect_to inbox_path
  end
 end


