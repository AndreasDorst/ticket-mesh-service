require 'rails_helper'
require_relative '../../app/workers/log_worker'
require_relative '../../app/services/exit_service' 
require_relative '../../app/services/exceptions'

RSpec.describe ExitService do

  let(:ticket) { create(:ticket) }

  describe '.process_exit' do
    context 'when the ticket is inside' do
      before do
         create(:access_log, ticket: ticket, status: 'entry')
      end

      it 'enqueues an exit log job' do
        expect {
          described_class.process_exit(ticket) 
        }.to change(AccessLogWorker.jobs, :size).by(1) 
      end
    end

    context 'when the ticket is not inside' do
      it 'raises TicketNotInsideError' do
        expect {
          described_class.process_exit(ticket)
        }.to raise_error(TicketNotInsideError, 'Not inside') 
      end
    end
  end
end