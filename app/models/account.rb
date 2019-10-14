class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  monetize :balance_cents
end
