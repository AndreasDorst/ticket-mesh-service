FactoryBot.define do
  factory :ticket do
    external_id { 123 }
    document_number { 'AB123' }
    category { 'base' }
    event_id { 1 }
    full_name { 'John Doe' }
  end

  factory :access_log do
    ticket
    status { 'entry' }
    check_time { Time.current }
  end
end