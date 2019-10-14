class PagesController < ApplicationController

   def testpage
    @transaction = Transaction.new
  end

  def import
  end

  def home
  end

  def profile
    @category = Category.new
  end
end
