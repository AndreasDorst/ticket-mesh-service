class TicketService
  def initialize(base_url = ENV['TICKET_SERVICE_URL'])
    @client = Faraday.new(url: base_url, headers: { 'Content-Type' => 'application/json' })
  end

  def fetch_ticket_info(ticket_id)
    response = @client.get("/api/ticket/info/#{ticket_id}")
    return nil unless response.success?

    JSON.parse(response.body)
  rescue Faraday::Error => e
    Rails.logger.error "TicketService error: #{e.message}"
    nil
  end
end