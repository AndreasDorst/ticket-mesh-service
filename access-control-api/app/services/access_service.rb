class AccessService
  def initialize(ticket)
    @ticket = ticket
  end

  def find_last_access
    @ticket.access_logs.order(check_time: :desc).first
  end

  def validate_reentry(last_log)
    return unless last_log

    if last_log.status == 'entry'
      raise StandardError, 'Already inside'
    elsif last_log.status == 'exit'
      { reentry: true }
    end
  end
end

helpers do
  def ticket_service
    @ticket_service ||= TicketService.new
  end

  def access_service(ticket)
    AccessService.new(ticket)
  end

  def verify_external_ticket(ticket_id, document_number)
    ticket_data = ticket_service.fetch_ticket_info(ticket_id)
    return nil unless ticket_data && ticket_data['document_number'] == document_number

    ticket_data
  end
end

post :entry do
  ticket = Ticket.find_by(external_id: params[:ticket_id])

  unless ticket
    ticket_data = verify_external_ticket(params[:ticket_id], params[:document_number])

    if ticket_data
      ticket = Ticket.create!(
        external_id: params[:ticket_id],
        document_number: params[:document_number],
        event_id: ticket_data['event_id'],
        full_name: ticket_data['full_name'],
        category: ticket_data['category']
      )
    else
      error!('Invalid credentials', 403)
    end
  end

  service = access_service(ticket)
  last_log = service.find_last_access

  begin
    service.validate_reentry(last_log)
  rescue StandardError => e
    error!(e.message, 409)
  end

  log = ticket.access_logs.create!(
    status: 'entry',
    check_time: Time.current
  )

  status 200
  { access_granted: true, log_id: log.id }
end