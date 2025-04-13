require 'faker'

AccessLog.delete_all
Ticket.delete_all

event_id = 1
event_start_time = Time.zone.local(2025, 4, 9, 19, 0, 0)
event_end_time = event_start_time + 2.hours

tickets = []
50.times do |i|
  tickets << Ticket.create!(
    external_id: 1000 + i,
    event_id: event_id,
    full_name: Faker::Name.name,
    document_number: "AB#{rand(100000..999999)}",
    category: rand(5) == 0 ? 'vip' : 'base',
    created_at: 3.weeks.ago
  )
end

puts "Создано:"
puts "- #{Ticket.count} билетов"
puts "- #{Ticket.where(category: 'vip').count} VIP билетов"
puts "- #{Ticket.where(category: 'base').count} обычных билетов"

AccessLog.transaction do # Используем транзакцию для целостности данных
  tickets.each do |ticket|
    # Случайным образом решаем, был ли вход для этого билета
    if rand < 0.8 # 80% билетов имеют запись о входе
      entry_time = event_start_time + rand(event_end_time - event_start_time)
      AccessLog.create!(
        ticket: ticket,
        status: 'entry',
        check_time: entry_time
      )
      puts "- Создан лог входа для билета #{ticket.external_id} в #{entry_time.strftime('%H:%M')}"

      # Случайным образом решаем, был ли выход (только если был вход)
      if rand < 0.2 # 20% вошедших билетов имеют запись о выходе
        exit_time = entry_time + rand((event_end_time + 1.hour) - entry_time)
        AccessLog.create!(
          ticket: ticket,
          status: 'exit',
          check_time: exit_time
        )
        puts "- Создан лог выхода для билета #{ticket.external_id} в #{exit_time.strftime('%H:%M')}"
      end
    end
  end
end

puts "- Создано #{AccessLog.count} логов доступа"