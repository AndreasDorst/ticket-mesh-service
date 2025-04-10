module API
  module V1
    class AccessLogs < Grape::API
      version 'v1', using: :path

      resources :access do
        desc 'Create access log'
        params do
          requires :ticket_id, type: Integer
          requires :event_id, type: Integer
          requires :full_name, type: String
          requires :document_number, type: String
          requires :status, type: String
          requires :category, type: String
        end
        
        post do
          LogWorker.perform_async(params)
          status :accepted
        end
      end
    end
  end
end