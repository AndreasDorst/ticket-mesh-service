require 'grape'
require 'date'

require_relative 'entities/ticket'
require_relative 'entities/access_log'

module API
  class AccessLogs < Grape::API
    format :json

    helpers do
      def ticket_service
        @ticket_service ||= Faraday.new(
          url: MICROSERVICES::TICKET_SERVICE,
          headers: {'Content-Type' => 'application/json'}
        )
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
        response = ticket_service.get("/api/ticket/info/#{ticket_id}")
        return nil unless response.success?

        ticket_data = JSON.parse(response.body)
        ticket_data if ticket_data['document_number'] == document_number
      rescue => e
        Rails.logger.error "Ticket verification failed: #{e}"
        nil
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

        last_log = find_last_access(ticket)
        error!('Not inside', 409) unless last_log && last_log.status == 'entry'

        log = ticket.access_logs.create!(
          status: 'exit',
          check_time: Time.current
        )
        status 200
        { exit_registered: true, log_id: log.id }
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
        logs = AccessLog.joins(:ticket)

        if params[:type]
          logs = logs.where(access_logs: { status: params[:type] })
        end

        if params[:status]
          logs = logs.where(access_logs: { status: params[:status] })
        end

        if params[:date]
          logs = logs.where('DATE(access_logs.check_time) = ?', params[:date])
        end

        present logs, with: Entities::AccessLog
      end
    end
  end
end
