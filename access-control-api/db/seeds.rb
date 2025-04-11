# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

require 'faker'

# Очищаем существующие данные
AccessLog.delete_all
Ticket.delete_all

# Создаем тестовые мероприятия
event_id = 1

# Генерируем билеты
tickets = []
20.times do |i|
  tickets << Ticket.create!(
    external_id: 1000 + i,
    event_id: event_id,
    full_name: Faker::Name.name,
    document_number: "AB#{rand(100000..999999)}",
    category: rand(5) == 0 ? 'vip' : 'base', # 20% VIP билетов
    created_at: 2.weeks.ago
  )
end

puts "Создано:"
puts "- #{Ticket.count} билетов"
puts "- #{Ticket.where(category: 'vip').count} VIP билетов"