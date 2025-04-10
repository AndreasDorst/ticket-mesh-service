class EventsController < ApplicationController
  def create
    event = Event.new(event_params)

    if event.save
      render json: event, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:event_name, :event_date, :base_tickets_amount, :vip_tickets_amount, :base_ticket_price, :vip_ticket_price)
  end
end
