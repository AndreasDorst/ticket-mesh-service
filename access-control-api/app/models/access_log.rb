class AccessLog < ApplicationRecord
  belongs_to :ticket

  validates :status, presence: true, 
            inclusion: { in: %w[entry exit fail] }
  validates :check_time, presence: true
end