class Booking < ApplicationRecord
  belongs_to :ticket

  def expired?
    expires_at < Time.current
  end
end
