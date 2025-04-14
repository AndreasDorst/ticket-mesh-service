class EventsController < ApplicationController
  class TicketServiceError < StandardError; end

  def create
    Rails.logger.info "Received parameters: #{params.inspect}"

    @event = nil

    ActiveRecord::Base.transaction do
      @event = Event.create!(event_params)

      Rails.logger.info "Created event: #{@event.inspect}, ID: #{@event.id}"

      url = "#{MICROSERVICES::TICKET_SERVICE}/api/ticket/bulk_create"
      headers = { 'Content-Type' => 'application/json' }
      body = {
        event_id: @event.id,
        base_tickets_count: @event.base_tickets_amount,
        vip_tickets_count: @event.vip_tickets_amount,
        base_price: @event.base_ticket_price,
        vip_price: @event.vip_ticket_price
      }.to_json

      response = Faraday.post(url, body, headers)

      unless response.status == 201
        raise TicketServiceError, response.body
      end
    end

    render json: { success: true, event_id: @event.id }

  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "Ticket Service connection failed: #{e.message}"
    render json: { error: "Service unavailable" }, status: :service_unavailable

  rescue TicketServiceError => e
    Rails.logger.error "Rollback (TicketServiceError): #{e.message}"
    render json: { error: "Failed to create event (Ticket Service Error)" }, status: :unprocessable_entity

  rescue => e
    Rails.logger.error "Unexpected error: #{e.message}"
    render json: { error: "Unexpected error" }, status: :unprocessable_entity
  end

  private

  def event_params
    params.require(:event).permit(
      :event_name, :event_date, :base_tickets_amount,
      :vip_tickets_amount, :base_ticket_price, :vip_ticket_price
    )
  end
end
