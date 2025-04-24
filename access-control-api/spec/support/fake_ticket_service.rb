require 'webmock/rspec'

module FakeTicketService
  extend WebMock::API

  def self.stub_requests
    stub_request(:get, %r{ticket-api:3000/api/ticket/info/\d+}).to_return(
      status: 200,
      body: {
        "ticket_id" => 123,
        "document_number" => "AB123",
        "event_id" => 1,
        "full_name" => "John Doe",
        "category" => "VIP"
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    stub_request(:get, "http://ticket-api:3000/api/ticket/info/456").to_return(status: 404)
  end
end