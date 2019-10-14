class DashboardController < ApplicationController
  respond_to :json

  def dashboard
    get_transactions_no_income
  end

  def balance_data
    @balance_data = User.first.balance_for_month(@selected_month)
    respond_to do |format|
      format.html { render "balance_data.json" }
      format.js
    end
  end

  def spent_data
    get_transactions_no_income
    @chart_spent_per_day = []
    date = Date.parse("1 #{@selected_month}")
    end_of_month = (date >> 1) - date.day
    num_days = end_of_month.day
    (1..num_days).each do |day|
      @chart_spent_per_day << get_day_spent_amount(day).abs
    end
    respond_to do |format|
      format.html { render "spent_data.json" }
      format.js
    end
  end

  def current_budgets_month
    sql_query = " \
        extract(month from month_from) = ? \
        AND extract(year from month_from) = ? \
      "
    month_as_date = Date.parse("1 #{@selected_month}")
    User.first.budgets.where(sql_query, month_as_date.month, month_as_date.year)
  end

  def budgeted_data
    current_budgets = current_budgets_month
    @budgeted_data = []
    @budget_cats = []
    @budget_colors = []
    User.first.categories.each do |category|
      unless category.no_cat? || category.income?
        budget = current_budgets.find_by(category: category)
        if budget
          @budgeted_data << (budget.amount_cents / 100)
        else
          @budgeted_data << 0
        end
        @budget_cats << category.name
        @budget_colors << category.color
      end
    end
    respond_to do |format|
      format.html { render "budgeted_data.json" }
      format.js
    end
  end

  def next_month
    @selected_month = (Date.parse("1 #{@selected_month}") >> 1).strftime("%B %y")
    session[:selected_month] = @selected_month
    @prev_month = (Date.parse("1 #{@selected_month}") - 2).strftime("%B %y")
    spent_data
  end

  def prev_month
    @selected_month = (Date.parse("1 #{@selected_month}") << 1).strftime("%B %y")
    session[:selected_month] = @selected_month
    @prev_month = (Date.parse("1 #{@selected_month}") - 2).strftime("%B %y")
    spent_data
    render action: :next_month
  end

  protected

  def get_day_spent_amount(day)
    amount = 0
    if @transactions_no_income.length.positive?
      day_trans = @transactions_no_income.where("extract(day from datetime) = #{day}")
      amount = day_trans.sum(:amount_cents) / 100 if day_trans.length.positive?
    end
    amount
  end
end
