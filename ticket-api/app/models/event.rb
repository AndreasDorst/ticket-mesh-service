class Event < ApplicationRecord
  has_many :tickets, dependent: :destroy

  validates :name, presence: true
  validates :date, presence: true
  validates :base_price, :vip_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end