class Tickets < Grape::API
  format :json
  prefix :api

  resource :ticket do
    desc 'Зарезервировать билет по event_id и категории'
    params do
      requires :event_id, type: Integer
      requires :category, type: String
    end
    post :book do
      Ticket.transaction do
        # Ищем подходящий доступный билет
        ticket = Ticket.available_for_booking(params[:event_id], params[:category]).first
  
        error!({ error: 'Нет доступных билетов' }, 404) unless ticket
  
        if ticket.booking&.expired?
          ticket.booking.destroy!
        elsif ticket.booking.present?
          error!({ error: 'Билет уже забронирован' }, 400)
        end

        time_to_book = 5.minutes.from_now

        # Создаем бронь для билета
        booking = Booking.create!(
          ticket: ticket,
          expires_at: time_to_book,
          user_document: nil # пока не указываем документ
        )
  
        {
          reservation_id: booking.id,
          price: ticket.price,
          expires_at: booking.expires_at.iso8601
        }
      end
    end
  end
end