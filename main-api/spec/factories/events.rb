FactoryBot.define do
  factory :event do
    event_name { 'Test event' }
    event_date { Date.tomorrow }
    base_tickets_amount { 100 }
    vip_tickets_amount { 10 }
    base_ticket_price { 50.0 }
    vip_ticket_price { 200.0 }
  end
end
