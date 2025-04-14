require 'rails_helper'
require 'webmock/rspec'

RSpec.describe EventsController, type: :request do
  describe "POST /events" do
    let(:event_params) do
      {
        event: {
          event_name: "My Event",
          event_date: Date.tomorrow,
          base_tickets_amount: 100,
          vip_tickets_amount: 50,
          base_ticket_price: 20.0,
          vip_ticket_price: 100.0
        }
      }
    end

    let(:ticket_service_url) { "#{MICROSERVICES::TICKET_SERVICE}/api/ticket/bulk_create" }

    before do
      # Статус успешного создания
      stub_request(:post, ticket_service_url)
        .to_return(status: 201, body: "", headers: {})
    end

    it "creates an event and calls the ticket service" do
      expect {
        post "/events", params: event_params
      }.to change(Event, :count).by(1)

      expect(response).to have_http_status(:ok)

      created_event = Event.last

      expect(WebMock).to have_requested(:post, ticket_service_url)
        .with(body: hash_including(
          event_id: created_event.id,
          base_tickets_count: 100,
          vip_tickets_count: 50,
          base_price: 20.0,
          vip_price: 100.0
        ))
    end

    context "when ticket service returns error" do
      before do
        stub_request(:post, ticket_service_url)
          .to_return(status: 422, body: "Some error")
      end

      it "does not persist the event and returns error" do
        expect {
          post "/events", params: event_params
        }.not_to change(Event, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to match(/Failed to create event/)
      end
    end

    context "when ticket service is unavailable" do
      before do
        stub_request(:post, ticket_service_url)
          .to_raise(Faraday::ConnectionFailed.new("Connection error"))
      end

      it "returns service unavailable error" do
        expect {
          post "/events", params: event_params
        }.not_to change(Event, :count)

        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)["error"]).to eq("Service unavailable")
      end
    end
  end
end
