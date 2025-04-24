ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
require 'sidekiq/testing'
require 'support/fake_ticket_service'

RSpec.shared_context 'Sidekiq testing' do
  before do
    Sidekiq::Testing.fake!
  end

  after do
    Sidekiq::Worker.clear_all
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.include FactoryBot::Syntax::Methods
  config.include RSpec::Rails::RequestExampleGroup

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
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

  config.around(:each) do |example|
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.cleaning { example.run }
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

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
