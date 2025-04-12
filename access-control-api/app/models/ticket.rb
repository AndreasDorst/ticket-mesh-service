class Ticket < ApplicationRecord
  has_many :access_logs, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :document_number, presence: true
  validates :category, inclusion: { in: %w[vip base] }, allow_nil: true
end
