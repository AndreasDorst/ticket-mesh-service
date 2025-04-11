RSpec.shared_context 'Sidekiq testing' do
  before do
    Sidekiq::Testing.fake!
  end

  after do
    Sidekiq::Worker.clear_all
  end
end