class Purchase < ApplicationRecord
  belongs_to :ticket

    validates :user_document, length: { maximum: 50 }
    validates :full_name, length: { maximum: 100 }
end
