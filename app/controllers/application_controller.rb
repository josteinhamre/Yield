class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :define_month

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end


  def default_url_options
  { host: ENV["DOMAIN"] || "localhost:3000" }
  end


  private

  def define_month
    if session[:selected_month]
      @selected_month = session[:selected_month]
      @prev_month = (Date.parse("1 #{@selected_month}") - 2).strftime("%B %y")
    else
      @selected_month = Date.today.strftime("%B %y")
      session[:selected_month] = @selected_month
      @prev_month = (Date.parse("1 #{@selected_month}") - 2).strftime("%B %y")
    end
  end

  def get_budgets
    sql_query = " \
        extract(month from month_from) = ? \
        AND extract(year from month_from) = ? \
      "
    month_as_date = Date.parse("1 #{@selected_month}")
    @budgets = User.first.budgets.where(sql_query, month_as_date.month, month_as_date.year)
  end

  def get_transactions
    sql_query = " \
        extract(month from datetime) = ? \
        AND extract(year from datetime) = ? \
      "
    date = Date.parse("1 #{@selected_month}")
    @transactions = User.first.transactions.where(sql_query, date.month, date.year)
  end

  def get_transactions_no_income
    sql_query = " \
        extract(month from datetime) = ? \
        AND extract(year from datetime) = ? \
      "
    date = Date.parse("1 #{@selected_month}")
    @transactions_no_income = User.first.transactions.where(sql_query, date.month, date.year).where.not(category: User.first.income_cat)
  end
end


