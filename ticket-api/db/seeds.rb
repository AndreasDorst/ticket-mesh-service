puts "Seeding tickets..."

# Очистка
Purchase.destroy_all
Ticket.destroy_all
Event.destroy_all
User.destroy_all

# Импорт пользователей из main-api (ручной клон для теста)
main_users = [
  { id: 1, full_name: "Alice Johnson", document_number: "AA123456" },
  { id: 2, full_name: "Bob Smith", document_number: "ID789123" },
  { id: 3, full_name: "Charlie Brown", document_number: "DL456789" },
  { id: 4, full_name: "Dana White", document_number: "AA999999" },
  { id: 5, full_name: "Eve Adams", document_number: "AB555666" }
]

main_users.each do |attrs|
  User.create!(attrs)
end

puts "Imported #{User.count} users from main-api"

# Создание событий
event1 = Event.create!(id: 1, name: "Concert A", date: Date.today + 2.days, base_price: 1000, vip_price: 2000)
event2 = Event.create!(id: 2, name: "Concert B", date: Date.today + 3.days, base_price: 1200, vip_price: 2500)

# Билеты
20.times do |i|
  Ticket.create!(category: i.even? ? 'vip' : 'base', status: 'available', event: [event1, event2].sample)
end

puts "Created #{Ticket.count} tickets"

# Покупки
users = User.all
Ticket.available.sample(5).each_with_index do |ticket, i|
  user = users[i % users.size]
  ticket.sold!
  Purchase.create!(ticket: ticket, user: user)
  puts "✓ Ticket ##{ticket.id} sold to #{user.full_name}"
end
