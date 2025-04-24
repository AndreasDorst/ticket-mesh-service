require 'rails_helper'

RSpec.describe AccessLogQuery do
  let!(:log1) { create(:access_log, status: 'entry', check_time: '2025-04-01', external: 'unique_1') }
  let!(:log2) { create(:access_log, status: 'exit', check_time: '2025-04-02', external: 'unique_2') }
  let!(:log3) { create(:access_log, status: 'fail', check_time: '2025-04-03', external: 'unique_3') }

  describe '#call' do
    it "filters logs by status" do
      result = AccessLogQuery.new(status: 'entry').call
      expect(result).to contain_exactly(log1)
    end

    it "filters logs by type (alias for status)" do
      result = AccessLogQuery.new(type: 'exit').call
      expect(result).to contain_exactly(log2)
    end
  end
end