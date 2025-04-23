FactoryBot.define do
  factory :access_log do
    status { 'entry' }
    check_time { Time.current }
    association :ticket
    sequence(:external) { |n| "external_#{n}" }
  end
end