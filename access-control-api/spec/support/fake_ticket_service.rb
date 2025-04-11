class FakeTicketService < Sinatra::Base
  get '/ticket/info/:id' do
    content_type :json

    case params[:id]
    when '123'
      { 
        document_number: 'AB123',
        event_id: 1,
        full_name: 'John Doe',
        category: 'base'
      }.to_json
    else
      status 404
      { error: 'Ticket not found' }.to_json
    end
  end
end