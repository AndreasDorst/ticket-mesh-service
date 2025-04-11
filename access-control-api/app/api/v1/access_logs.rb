require 'grape'

module API
  module V1
    class AccessLogs < Grape::API
      version 'v1', using: :path

      helpers do
        def ticket_service
          @ticket_service ||= Faraday.new(
            url: 'http://ticket-service',
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
          response = ticket_service.get("/ticket/info/#{ticket_id}")
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
          # 1. Поиск или создание билета
          ticket = Ticket.find_by(external_id: params[:ticket_id])
          error!('Ticket not found', 404) unless ticket

          # 2. Проверка последнего статуса
          last_log = find_last_access(ticket)
          validate_reentry(last_log)

          # 3. Внешняя проверка
          ticket_data = verify_external_ticket(params[:ticket_id], params[:document_number])
          error!('Invalid credentials', 403) unless ticket_data

          # 4. Создание записи входа
          log = ticket.access_logs.create!(
            status: 'entry',
            check_time: Time.current
          )

          { access_granted: true, log_id: log.id }
        end

        desc 'Process exit attempt'
        params do
          requires :ticket_id, type: Integer
        end
        post :exit do
          # 1. Поиск билета
          ticket = Ticket.find_by(external_id: params[:ticket_id])
          error!('Ticket not found', 404) unless ticket

          # 2. Проверка последнего статуса
          last_log = find_last_access(ticket)
          error!('Not inside', 409) unless last_log&.status == 'entry'

          # 3. Создание записи выхода
          log = ticket.access_logs.create!(
            status: 'exit',
            check_time: Time.current
          )

          { exit_registered: true, log_id: log.id }
        end
      end
    end
  end
end
