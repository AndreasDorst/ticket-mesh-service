require_relative '../workers/log_worker' 
require_relative '../services/exceptions' 
require_relative '../services/access_service'
require_relative '../services/exit_service'
require_relative '../services/ticket_service'

module API
  class AccessLogs < Grape::API
    format :json
    prefix :api

    helpers do
      def ticket_service
        @ticket_service ||= TicketService.new
      end

      def verify_external_ticket(ticket_id, document_number)
        service = ticket_service
        ticket_data = service.fetch_ticket_info(ticket_id)
        ticket_data if ticket_data && ticket_data["document_number"] == document_number
      end
    end

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

        begin
          AccessService.process_entry(ticket)

          status 200
          { access_granted: true }

        rescue TicketAlreadyInsideError => e
          error!(e.message, 409)
        rescue ServiceError => e
           Rails.logger.error "Known Service Error during entry processing: #{e.message}"
           error!({ error: e.message }, 400)
        rescue StandardError => e
           Rails.logger.error "Unexpected error during entry processing: #{e.message}\n#{e.backtrace.join("\n")}"
           error!({ error: 'Internal server error during entry processing' }, 500)
        end
      end

      desc 'Process exit attempt'
      params do
        requires :ticket_id, type: Integer, desc: 'Ticket ID'
      end
      post :exit do
        ticket = Ticket.find_by(external_id: params[:ticket_id].to_s)
        error!('Ticket not found', 404) unless ticket

        begin
          ExitService.process_exit(ticket)

          status 200
          { exit_registered: true }

        rescue TicketNotInsideError => e
          error!(e.message, 409)
        rescue ServiceError => e 
           Rails.logger.error "Known Service Error during exit processing: #{e.message}"
           error!({ error: e.message }, 400)
        rescue StandardError => e
           Rails.logger.error "Unexpected error during exit processing: #{e.message}\n#{e.backtrace.join("\n")}"
           error!({ error: 'Internal server error during exit processing' }, 500)
        end
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