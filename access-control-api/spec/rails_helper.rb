require_relative '../config/environment'
require_relative '../app/api/v1/access_logs'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'webmock/rspec'
require 'sidekiq/testing'

RSpec.shared_context 'Sidekiq testing' do
  before do
    Sidekiq::Testing.fake!
  end

  after do
    Sidekiq::Worker.clear_all
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include RSpec::Rails::RequestExampleGroup

  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
