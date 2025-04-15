AccessLog.delete_all
Ticket.delete_all

event_id = 1
event_start_time = Time.zone.local(2025, 4, 9, 19, 0, 0)
event_end_time = event_start_time + 2.hours

# Задаём фиксированные билеты — эти данные должны соответствовать ticket-api/main-api
tickets_data = [
  { external_id: 1, full_name: "Alice Johnson", document_number: "AA123456", category: "base" },
  { external_id: 2, full_name: "Bob Smith", document_number: "ID789123", category: "vip" },
  { external_id: 3, full_name: "Charlie Brown", document_number: "DL456789", category: "base" },
  { external_id: 4, full_name: "Dana White", document_number: "AA999999", category: "vip" },
  { external_id: 5, full_name: "Eve Adams", document_number: "AB555666", category: "base" }
]

tickets = tickets_data.map do |attrs|
  Ticket.create!(
    external_id: attrs[:external_id],
    event_id: event_id,
    full_name: attrs[:full_name],
    document_number: attrs[:document_number],
    category: attrs[:category],
    created_at: 3.weeks.ago
  )
end

puts "Создано:"
puts "- #{Ticket.count} билетов"
puts "- #{Ticket.where(category: 'vip').count} VIP билетов"
puts "- #{Ticket.where(category: 'base').count} обычных билетов"

# Добавим логи доступа (вход/выход)
AccessLog.transaction do
  tickets.each do |ticket|
    if rand < 0.8  # 80% билетов с логом входа
      entry_time = event_start_time + rand(event_end_time - event_start_time)
      AccessLog.create!(
        ticket: ticket,
        status: 'entry',
        check_time: entry_time
      )
      puts "- Создан лог входа для билета #{ticket.external_id} в #{entry_time.strftime('%H:%M')}"

      if rand < 0.2  # 20% с логом выхода
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