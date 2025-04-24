FactoryBot.define do
  factory :ticket do
    sequence(:external_id) { |n| n.to_s }
    document_number { "AB123" }
    event_id { 1 }
    full_name { "John Doe" }
    category { "vip" }
  end
end