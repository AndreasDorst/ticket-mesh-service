class Ticket < ApplicationRecord
  enum status: {
    available: 0,
    sold: 1,
    blocked: 2
  }

  enum category: {
    base: "base",
    vip: "vip"
  }

  validates :category, presence: true, inclusion: { in: categories.keys }

  has_one :booking, dependent: :destroy # Один билет может иметь только одну бронь
  has_one :purchase

  # Скоуп для поиска билетов, которые доступны для бронирования
  scope :available_for_booking, ->(event_id, category) {
    left_outer_joins(:booking)
      .where(event_id: event_id, category: category, status: :available)
      .where('bookings.id IS NULL OR bookings.expires_at < ?', Time.current)
  }

  def self.price_for_category(event_id, category, base_price)
    total = where(event_id: event_id, category: category).count
    sold  = where(event_id: event_id, category: category, status: :sold).count

    # Считаем актуальные брони (не истёкшие)
    booked = joins(:booking)
              .where(event_id: event_id, category: category, status: :available)
              .where('bookings.expires_at > ?', Time.current)
              .count
  
    return base_price if total.zero?
  
    sold_ratio = (sold + booked).to_f / total
    multiplier = (sold_ratio * 10).floor
  
    (base_price * (1 + 0.1 * multiplier)).to_i
  end
end
