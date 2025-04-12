module API
  module Entities
    class AccessLog < Grape::Entity
      expose :check_time, as: :timestamp
      expose :status
      expose :ticket, using: Entities::Ticket do |access_log|
        access_log.ticket
      end
    end
  end
end