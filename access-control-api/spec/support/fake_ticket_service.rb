require 'webmock/rspec'

module FakeTicketService
  extend WebMock::API

  def self.stub_requests
    stub_request(:get, %r{localhost:3001/api/ticket/info/}).to_return(
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
  end
end