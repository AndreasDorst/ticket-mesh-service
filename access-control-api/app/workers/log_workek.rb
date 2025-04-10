class LogWorker
  include Sidekiq::Worker

  def perform(log_data)
    AccessLog.create(log_data)
  end
end