class ExitService
  def initialize(ticket)
    @ticket = ticket
  end

  def process_exit
    last_log = find_last_access
    raise StandardError, 'Not inside' unless last_log&.status == 'entry'

    @ticket.access_logs.create!(
      status: 'exit',
      check_time: Time.current
    )
  end

  private

  def find_last_access
    @ticket.access_logs.order(check_time: :desc).first
  end
end