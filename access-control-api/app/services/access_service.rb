require_relative '../workers/log_worker'
require_relative 'exceptions'

class AccessService
  def self.process_entry(ticket)
    last_log = ticket.access_logs.order(check_time: :desc).first

    if last_log&.status == 'entry'
      raise TicketAlreadyInsideError, 'Already inside'
    end

    AccessLogWorker.perform_async(
      'ticket_id' => ticket.id,
      'status' => 'entry',
      'check_time' => Time.current.iso8601
    )
  end
end