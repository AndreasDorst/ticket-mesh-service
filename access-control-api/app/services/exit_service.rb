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

post :exit do
  ticket = Ticket.find_by(external_id: params[:ticket_id])
  error!('Ticket not found', 404) unless ticket

  begin
    service = ExitService.new(ticket)
    log = service.process_exit
    status 200
    { exit_registered: true, log_id: log.id }
  rescue StandardError => e
    error!(e.message, 409)
  end
end