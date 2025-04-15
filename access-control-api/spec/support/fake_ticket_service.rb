require 'webmock/rspec'

module FakeTicketService
  extend WebMock::API

  def self.stub_requests
    stub_request(:get, %r{#{MICROSERVICES::TICKET_SERVICE}/api/ticket/info/\d+}).to_return do |request|
      ticket_id = request.uri.path.split('/').last

      case ticket_id
      when '123'
        {
          status: 200,
          body: {
            document_number: 'AB123',
            event_id: 1,
            full_name: 'John Doe',
            category: 'base'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      when '456'
        {
          status: 200,
          body: { document_number: 'WRONG' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      when '789'
        {
          status: 200,
          body: {
            document_number: 'AB789',
            event_id: 1,
            full_name: 'John Doe',
            category: 'base'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      when '999'
        {
          status: 200,
          body: {
            document_number: 'CD123',
            event_id: 1,
            full_name: 'John Doe',
            category: 'base'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      else
        {
          status: 404,
          body: { error: 'Ticket not found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end
    end
  end
end