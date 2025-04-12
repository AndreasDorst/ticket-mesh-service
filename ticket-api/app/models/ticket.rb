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
end
