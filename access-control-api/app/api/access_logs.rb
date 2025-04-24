require_relative '../workers/log_worker'

module API
  class AccessLogs < Grape::API
    format :json
    prefix :api

    resource :access do
      desc 'Process entry attempt'
      params do
        requires :ticket_id, type: Integer, desc: 'Ticket ID'
        requires :document_number, type: String, desc: 'Document number'
      end
      post :entry do
        ticket = Ticket.find_by(external_id: params[:ticket_id].to_s)
        unless ticket
          ticket_data = verify_external_ticket(params[:ticket_id], params[:document_number])
          error!('Invalid credentials', 403) unless ticket_data
          ticket = Ticket.create!(
            external_id: params[:ticket_id].to_s,
            document_number: params[:document_number],
            category: ticket_data['category'].downcase
          )
        end

        last_log = ticket.access_logs.order(check_time: :desc).first
        if last_log&.status == 'entry'
          error!('Already inside', 409)
        end

        AccessLogWorker.perform_async(
          'ticket_id' => ticket.id,
          'status' => 'entry',
          'check_time' => Time.current.to_s
        )

        status 200
        { access_granted: true }
      end

      desc 'Process exit attempt'
      params do
        requires :ticket_id, type: Integer, desc: 'Ticket ID'
      end
      post :exit do
        ticket = Ticket.find_by(external_id: params[:ticket_id].to_s)
        error!('Ticket not found', 404) unless ticket

        last_log = ticket.access_logs.order(check_time: :desc).first
        if !last_log || last_log.status != 'entry'
          error!('Not inside', 409)
        end

        AccessLogWorker.perform_async(
          'ticket_id' => ticket.id,
          'status' => 'exit',
          'check_time' => Time.current.to_s
        )

        status 200
        { exit_registered: true }
      end
    end

    resource :access_logs do
      desc 'Get a list of access logs with filtering'
      params do
        optional :type, type: String, values: %w[entry exit], desc: 'Filter by event type'
        optional :status, type: String, values: %w[entry exit fail], desc: 'Filter by status'
        optional :date, type: Date, desc: 'Filter by date (YYYY-MM-DD)'
      end
      get do
        logs = AccessLogQuery.new(params).call
        present logs, with: Entities::AccessLog
      end
    end

    helpers do
      def verify_external_ticket(ticket_id, document_number)
        service = TicketService.new
        ticket_data = service.fetch_ticket_info(ticket_id)
        ticket_data if ticket_data && ticket_data["document_number"] == document_number
      end
    end
  end
end