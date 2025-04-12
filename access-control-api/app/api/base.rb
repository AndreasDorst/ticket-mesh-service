module API
  class Base < Grape::API
    format :json

    mount API::AccessLogs

    rescue_from :all do |e|
      error!({ error: e.message }, 500)
    end
  end
end
