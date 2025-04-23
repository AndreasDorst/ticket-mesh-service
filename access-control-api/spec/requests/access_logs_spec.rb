require 'rails_helper'
require 'webmock/rspec'
require_relative '../support/fake_ticket_service'

RSpec.describe 'Access API', type: :request do
  before { FakeTicketService.stub_requests }
  let(:headers) { { 'Accept' => 'application/json' } }

  describe 'POST /api/access/entry' do
    context 'successful entry' do
      it 'grants access and creates a new log' do
        post '/api/access/entry', params: { ticket_id: 123, document_number: 'AB123' }, headers: headers
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json).to include('access_granted' => true)
      end
    end

    context 'unsuccessful entry due to invalid credentials' do
      it 'rejects access with 403' do
        stub_request(:get, %r{localhost:3001/api/ticket/info/456}).to_return(status: 404)
        post '/api/access/entry', params: { ticket_id: 456, document_number: 'INVALID' }, headers: headers
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST /api/access/exit' do
    # Your exit endpoint tests here…
  end
end