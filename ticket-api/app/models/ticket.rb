class Ticket < ApplicationRecord
  enum status: {
    available: 0,
    booked: 1,
    sold: 2,
    blocked: 3
  }
end
