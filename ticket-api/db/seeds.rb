puts "Seeding tickets..."

# Очистим таблицу для повторного запуска
Ticket.destroy_all

# Создание тестовых билетов
10.times do |i|
  Ticket.create!(
    category: :base,
    status: :available,
    price: 2000,
    event_id: i % 2,
    event_date: Date.today + (i % 5).days,
    base_price: 1800,
    sold_percentage: 0
  )
end

5.times do |i|
  Ticket.create!(
    category: :vip,
    status: :available,
    price: 4000,
    event_id: i % 2,
    event_date: Date.today + (i % 5).days,
    base_price: 3500,
    sold_percentage: 0
  )
end

# Несколько уже проданных
Ticket.create!(
  category: :vip,
  status: :sold,
  price: 4500,
  event_id: 1,
  event_date: Date.today + 2.days,
  base_price: 3500,
  sold_percentage: 0
)

puts "Done seeding!"