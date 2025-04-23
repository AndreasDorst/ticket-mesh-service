require 'rails_helper'

RSpec.describe AccessLogQuery do
  let!(:log1) { create(:access_log, status: 'entry', check_time: '2025-04-01') }
  let!(:log2) { create(:access_log, status: 'exit', check_time: '2025-04-02') }
  let!(:log3) { create(:access_log, status: 'fail', check_time: '2025-04-03') }

  describe '#call' do
    it 'filters by type' do
      result = described_class.new(type: 'entry').call
      expect(result).to contain_exactly(log1)
    end

    it 'filters by status' do
      result = described_class.new(status: 'exit').call
      expect(result).to contain_exactly(log2)
    end

    it 'filters by date' do
      result = described_class.new(date: '2025-04-03').call
      expect(result).to contain_exactly(log3)
    end

    it 'applies multiple filters' do
      result = described_class.new(status: 'entry', date: '2025-04-01').call
      expect(result).to contain_exactly(log1)
    end
  end
end