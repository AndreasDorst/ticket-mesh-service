require_relative '../workers/log_worker'

class ExitService
  def self.process_exit(ticket)
    last_log = ticket.access_logs.order(check_time: :desc).first

    if !last_log || last_log.status != 'entry'
      raise TicketNotInsideError, 'Not inside'
    end

    AccessLogWorker.perform_async(
      'ticket_id' => ticket.id,
      'status' => 'exit',
      'check_time' => Time.current.iso8601
    )
  end
end