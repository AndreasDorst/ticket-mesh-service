puts "Seeding tickets..."

# Очистка
Purchase.destroy_all
Ticket.destroy_all
Event.destroy_all
User.destroy_all

# Импорт пользователей из main-api (ручной клон для теста)
main_users = [
  { external_id: 1, full_name: "Alice Johnson", document_number: "AA123456", category: "base" },
  { external_id: 2, full_name: "Bob Smith", document_number: "ID789123", category: "vip" },
  { external_id: 3, full_name: "Charlie Brown", document_number: "DL456789", category: "base" },
  { external_id: 4, full_name: "Dana White", document_number: "AA999999", category: "vip" },
  { external_id: 5, full_name: "Eve Adams", document_number: "AB555666", category: "base" }
]

# Создание пользователей
main_users.each do |attrs|
  User.create!(attrs.slice(:full_name, :document_number))
end

puts "Imported #{User.count} users from main-api"

# Создание событий
event1 = Event.create!(name: "Concert A", date: Date.today + 2.days, base_price: 1000, vip_price: 2000)
event2 = Event.create!(name: "Concert B", date: Date.today + 3.days, base_price: 1200, vip_price: 2500)

# Создание билетов в соответствии с main-api
main_users.each do |user_data|
  Ticket.create!(
    category: user_data[:category],
    status: 'available',
    event: [event1, event2].sample
  )
end

puts "Created #{Ticket.count} tickets (1 per user, category-matched)"

# Покупки
users = User.all
Ticket.available.each_with_index do |ticket, i|
  user = users[i]
  ticket.sold!
  Purchase.create!(ticket: ticket, user: user)
  puts "✓ Ticket ##{ticket.id} sold to #{user.full_name}"
end
