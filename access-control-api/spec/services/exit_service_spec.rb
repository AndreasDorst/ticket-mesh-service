require 'rails_helper'

RSpec.describe ExitService do
  let(:ticket) { create(:ticket) }
  let(:service) { described_class.new(ticket) }

  describe '#process_exit' do
    context 'when the ticket is inside' do
      it 'creates an exit log' do
        create(:access_log, ticket: ticket, status: 'entry')
        log = service.process_exit
        expect(log.status).to eq('exit')
      end
    end

    context 'when the ticket is not inside' do
      it 'raises an error' do
        expect { service.process_exit }.to raise_error(StandardError, 'Not inside')
      end
    end
  end
end