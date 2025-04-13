class Purchase < ApplicationRecord
  belongs_to :ticket
  belongs_to :user, optional: true # если у тебя нет модели User, то оставь просто user_id

  validates :user_document, length: { maximum: 50 }
  validates :full_name, length: { maximum: 100 }

  validate :unique_purchase_per_event

  private

  def unique_purchase_per_event
    return unless ticket && user_id

    existing = Purchase.joins(:ticket)
                       .where(user_id: user_id, tickets: { event_id: ticket.event_id })
                       .where.not(id: id)
                       .exists?

    if existing
      errors.add(:base, "User has already purchased a ticket for this event")
    end
  end
end
