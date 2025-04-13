require 'faker'

puts "Seeding tickets..."

# Очистим таблицы
Purchase.destroy_all
Ticket.destroy_all

# Создание тестовых билетов
10.times do |i|
  Ticket.create!(
    category: :base,
    status: :available,
    event_id: i % 2,
    event_date: Date.today + (i % 5).days,
    base_price: 1000,
  )
end

5.times do |i|
  Ticket.create!(
    category: :vip,
    status: :available,
    event_id: i % 2,
    event_date: Date.today + (i % 5).days,
    base_price: 2000,
  )
end

# Несколько уже проданных вручную
Ticket.create!(
  category: :vip,
  status: :sold,
  event_id: 1,
  event_date: Date.today + 2.days,
  base_price: 3500,
)

puts "Seeding purchases..."

# Создание фейковых покупок
purchased_tickets = Ticket.where(status: :available).sample(7)
purchased_tickets.each do |ticket|
  ticket.update!(status: :sold)

  full_name = Faker::Name.name
  document = Faker::IdNumber.valid.gsub(/[^\d]/, '')[0, 50]
  user_id = SecureRandom.uuid

  Purchase.create!(
    ticket: ticket,
    user_id: user_id,
    timestamp: Time.current,
    user_document: document,
    full_name: full_name
  )

  puts "✓ Ticket ##{ticket.id} sold to #{full_name} (#{document}), user_id: #{user_id}"
end


puts "Seeding unsold tickets..."
10.times do |i|
  Ticket.create!(
    category: :base,
    status: :available,
    event_id: 2,
    event_date: Date.today + 1.days,
    base_price: 1000,
  )
end

puts "Done seeding!"
