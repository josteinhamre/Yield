class CategoriesController < ApplicationController
  def index
    get_budgets
    get_transactions
  end

  def prev_month
    @selected_month = (Date.parse("1 #{@selected_month}") << 1).strftime("%B %y")
    session[:selected_month] = @selected_month
    @prev_month = (Date.parse("1 #{@selected_month}") - 2).strftime("%B %y")
    get_budgets
    get_transactions
  end

  def next_month
    @selected_month = (Date.parse("1 #{@selected_month}") >> 1).strftime("%B %y")
    session[:selected_month] = @selected_month
    @prev_month = (Date.parse("1 #{@selected_month}") - 2).strftime("%B %y")
    get_budgets
    get_transactions
  end

  def create
    @category = Category.new(category_params)
    @category.user = User.first
    @category.save
    respond_to do |format|
      format.html { redirect_to profile_path }
      format.js # <-- will render `app/views/categories/create.js.erb
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :color, :icon_id)
  end
end
