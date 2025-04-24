class TicketService
  BASE_URL = ENV.fetch('TICKET_SERVICE_URL', 'http://localhost:3001')

  def initialize
    @client = Faraday.new(url: BASE_URL)
  end

  def fetch_ticket_info(ticket_id)
    response = @client.get("/api/ticket/info/#{ticket_id}")
    return nil unless response.status == 200
    JSON.parse(response.body)
  end
end