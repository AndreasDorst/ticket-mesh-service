class AccessLogWorker
  include Sidekiq::Worker

  def perform(log_data)
    AccessLog.create!(log_data)
  rescue => e
    Rails.logger.error "Access log failed: #{e.message}"
    retry unless exceeded_retries?
  end
end