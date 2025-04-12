require 'rails_helper'
require 'webmock/rspec'

require_relative '../support/fake_ticket_service'

RSpec.describe 'Access API', type: :request do
  include_context 'Sidekiq testing'

  let(:headers) { { 'Accept' => 'application/json' } }

  before do
    FakeTicketService.stub_requests
  end

  describe 'POST /api/access/entry' do
    context 'successful entry for a new ticket' do
      it 'grants access and creates a new ticket' do
        post '/api/access/entry', params: { ticket_id: 123, document_number: 'AB123' }, headers: headers
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include('access_granted' => true)
        expect(Ticket.find_by(external_id: 123)).to be_present
      end
    end

    context 'unsuccessful entry due to invalid credentials' do
      it 'rejects access and does not create a new ticket' do
        post '/api/access/entry', params: { ticket_id: 456, document_number: 'INVALID' }, headers: headers
        expect(response).to have_http_status(403)
        expect(Ticket.find_by(external_id: 456)).to be_nil
      end
    end

    context 're-entry after exit' do
      it 'grants access and updates the existing ticket status' do
        ticket = create(:ticket, external_id: 789, document_number: 'AB789')
        create(:access_log, ticket: ticket, status: 'exit')
        post '/api/access/entry', params: { ticket_id: 789, document_number: 'AB789' }, headers: headers
        expect(response).to have_http_status(:success)
        expect(AccessLog.last.status).to eq('entry')
      end
    end

    context 'already inside' do
      it 'rejects access with a 409 status' do
        ticket = create(:ticket, external_id: 999, document_number: 'CD123')
        create(:access_log, ticket: ticket, status: 'entry')
        post '/api/access/entry', params: { ticket_id: 999, document_number: 'CD123' }, headers: headers
        expect(response).to have_http_status(409)
      end
    end
  end

  describe 'POST /api/access/exit' do
    context 'successful exit' do
      it 'registers the exit' do
        ticket = create(:ticket, external_id: 111)
        create(:access_log, ticket: ticket, status: 'entry')

        post '/api/access/exit', params: { ticket_id: 111 }, headers: headers
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include('exit_registered' => true)
        expect(AccessLog.last.status).to eq('exit')
      end
    end

    context 'unsuccessful exit - ticket not found' do
      it 'returns a 404 status' do
        post '/api/access/exit', params: { ticket_id: 999 }, headers: headers
        expect(response).to have_http_status(404)
      end
    end

    context 'unsuccessful exit - not inside' do
      it 'returns a 409 status' do
        ticket = create(:ticket, external_id: 222)
        create(:access_log, ticket: ticket, status: 'exit')

        post '/api/access/exit', params: { ticket_id: 222 }, headers: headers
        expect(response).to have_http_status(409)
      end
    end
  end
end
