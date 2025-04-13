module API
  module Entities
    class Ticket < Grape::Entity
      expose :external_id
      expose :full_name
    end
  end
end