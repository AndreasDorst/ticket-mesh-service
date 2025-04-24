require 'faraday'
require 'json'

class TicketService
  BASE_URL = ENV.fetch('TICKET_SERVICE_URL', 'http://localhost:3000')

  def initialize
    @client = Faraday.new(url: BASE_URL)
  end

  def fetch_ticket_info(ticket_id)
    response = @client.get("/api/ticket/info/#{ticket_id}")
    return nil unless response.status == 200
    JSON.parse(response.body)
  rescue Faraday::Error => e
    Rails.logger.error "Faraday error calling TicketService /info/#{ticket_id}: #{e.message}"
    nil
  end
end