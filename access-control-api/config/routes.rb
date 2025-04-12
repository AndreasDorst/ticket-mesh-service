Rails.application.routes.draw do
  mount API::Base => '/api'

  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
end
