class Event < ApplicationRecord
  validates :event_name, presence: true
  validates :event_date, presence: true
  validates :base_tickets_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :vip_tickets_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :base_ticket_price, numericality: { greater_than_or_equal_to: 0 }
  validates :vip_ticket_price, numericality: { greater_than_or_equal_to: 0 }
end
