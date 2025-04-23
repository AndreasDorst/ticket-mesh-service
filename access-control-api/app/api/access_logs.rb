require 'grape'
require 'date'

require_relative 'entities/ticket'
require_relative 'entities/access_log'

module API
  class AccessLogs < Grape::API
    format :json

    helpers do
      def ticket_service
        @ticket_service ||= TicketService.new
      end

      def find_last_access(ticket)
        ticket.access_logs.order(check_time: :desc).first
      end

      def validate_reentry(last_log)
        return unless last_log

        if last_log.status == 'entry'
          error!('Already inside', 409)
        elsif last_log.status == 'exit'
          { reentry: true }
        end
      end

      def verify_external_ticket(ticket_id, document_number)
        ticket_data = ticket_service.fetch_ticket_info(ticket_id)
        return nil unless ticket_data && ticket_data['document_number'] == document_number

        ticket_data
      end
    end

    resource :access do
      desc 'Process entry attempt'
      params do
        requires :ticket_id, type: Integer
        requires :document_number, type: String
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

        last_log = find_last_access(ticket)
        if last_log&.status == 'entry'
          error!('Already inside', 409)
        elsif last_log&.status == 'exit'
          last_log.update!(status: 'entry')
          log = last_log
        else
          log = ticket.access_logs.create!(
            status: 'entry',
            check_time: Time.current
          )
        end
        status 200
        { access_granted: true, log_id: log.id }
      end

      desc 'Process exit attempt'
      params do
        requires :ticket_id, type: Integer
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
    end

    resource :access_logs do
      desc 'Get a list of access logs with filtering'
      params do
        optional :type, type: String, values: %w[entry exit], desc: 'Filter by entry or exit type'
        optional :status, type: String, values: %w[entry exit fail], desc: 'Filter by status (entry, exit, fail)'
        optional :date, type: Date, desc: 'Filter by date (YYYY-MM-DD)'
      end
      get do
        logs = AccessLogQuery.new(params).call
        present logs, with: Entities::AccessLog
      end
    end
  end
end
