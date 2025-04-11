module V1
  class Tickets < Grape::API
    format :json
    prefix :api

    resource :ticket do
      desc 'Get ticket price'
      params do
        requires :category, type: String
        requires :event_id, type: Integer
      end
      post :price do
        ticket = Ticket.find_by(
          event: params[:event_id],
          category: params[:category],
          status: :available
        )

        if ticket
          { price: ticket.price }
        else
          error!({ error: 'No available ticket found' }, 404)
        end
      end
    end
  end
end
