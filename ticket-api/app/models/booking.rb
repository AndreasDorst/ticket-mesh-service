class Booking < ApplicationRecord
  belongs_to :ticket

  RESERVATION_DURATION = 5.minutes

  def self.default_expiration
    RESERVATION_DURATION.from_now
  end

  def expired?
    expires_at < Time.current
  end
end
