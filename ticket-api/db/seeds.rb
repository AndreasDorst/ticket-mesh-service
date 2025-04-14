require 'faker'

puts "Seeding tickets..."

# Очистим таблицы
Purchase.destroy_all
Ticket.destroy_all
Event.destroy_all
User.destroy_all

# Создание событий
event1 = Event.create!(
  id: 1,
  name: "Concert A",
  date: Date.today + 2.days,
  base_price: 1000,
  vip_price: 2000
)

event2 = Event.create!(
  id: 2,
  name: "Concert B",
  date: Date.today + 3.days,
  base_price: 1200,
  vip_price: 2500
)

puts "Created events: Concert A, Concert B"

# Создание тестовых билетов
10.times do |i|
  Ticket.create!(
    category: 'base',
    status: 'available',
    event_id: event1.id,
    created_at: Time.current,
    updated_at: Time.current
  )
end

5.times do |i|
  Ticket.create!(
    category: 'vip',
    status: 'available',
    event_id: event2.id,
    created_at: Time.current,
    updated_at: Time.current
  )
end

# Несколько уже проданных вручную
Ticket.create!(
  category: 'vip',
  status: 'sold',
  event_id: event1.id,
  created_at: Time.current,
  updated_at: Time.current
)

puts "Seeding users..."

# Создание пользователей
10.times do |i|
  User.create!(
    full_name: Faker::Name.name,
    document_number: Faker::IdNumber.valid,
    created_at: Time.current,
    updated_at: Time.current
  )
end

puts "Created 10 users."

puts "Seeding purchases..."

# Создание фейковых покупок
users = User.all.shuffle  # Сортируем всех пользователей случайным образом
user_index = 0  # Индекс для отслеживания текущего пользователя

purchased_tickets = Ticket.where(status: 'available').sample(7)
purchased_tickets.each do |ticket|
  ticket.sold!

  # Выбираем следующего пользователя из отсортированного списка
  user = users[user_index]
  user_index += 1  # Переходим к следующему пользователю

  # Создаем покупку
  Purchase.create!(
    ticket: ticket,
    user: user,
    purchased_at: Time.current
  )

  puts "✓ Ticket ##{ticket.id} sold to #{user.full_name} (#{user.document_number}), user_id: #{user.id}"
end

puts "Seeding unsold tickets..."
# Несколько не проданных билетов
10.times do |i|
  Ticket.create!(
    category: 'base',
    status: 'available',
    event_id: event2.id,
    created_at: Time.current,
    updated_at: Time.current
  )
end

puts "Done seeding!"
