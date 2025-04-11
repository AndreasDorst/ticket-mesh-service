require 'rails_helper'

RSpec.describe 'Access API', type: :request do
  include_context 'Sidekiq testing'

  let!(:valid_ticket) { create(:ticket, external_id: 123, document_number: 'AB123') }
  let(:headers) { { 'Accept' => 'application/json' } }

  before do
    stub_request(:get, "http://ticket-service/ticket/info/123")
      .to_return(
        status: 200,
        body: {
          'document_number' => 'AB123',
          'event_id' => 1,
          'full_name' => 'John Doe',
          'category' => 'base'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'POST /api/v1/access/entry' do
    context 'with valid credentials' do
      it 'grants access' do
        post '/api/v1/access/entry', params: {
          ticket_id: 123,
          document_number: 'AB123'
        }, headers: headers

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include('access_granted' => true)
      end
    end
  end
end
