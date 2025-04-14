class User < ApplicationRecord
  has_one :purchase, dependent: :destroy

  validates :full_name, presence: true
  validates :document_number, presence: true
end