require_relative 'access_logs'

module API
  class Base < Grape::API
    mount API::AccessLogs
  end
end
