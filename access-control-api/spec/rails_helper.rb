ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'webmock/rspec'
require 'sidekiq/testing'
require 'support/fake_ticket_service'

require_relative '../app/api/access_logs'
require_relative '../app/api/base'

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
    FakeTicketService.stub_requests
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
    FakeTicketService.stub_requests
  end

  config.before(:all) do
    DatabaseCleaner.start
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end

  if Rails.env.test?
    DatabaseCleaner.allow_remote_database_url = true
  end
end
