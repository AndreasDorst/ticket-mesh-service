class Booking < ApplicationRecord
  belongs_to :ticket

  # Проверка истечения срока брони
  def expired?
    expires_at < Time.current
  end
end
