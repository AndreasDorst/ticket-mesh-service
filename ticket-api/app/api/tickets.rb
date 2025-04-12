class Tickets < Grape::API
  format :json
  prefix :api

  resource :ticket do    
    desc 'Book ticket by event_id and category'
    params do
      requires :event_id, type: Integer
      requires :category, type: String
    end
    post :book do
      Ticket.transaction do
        # Ищем подходящий доступный билет
        ticket = Ticket.available_for_booking(params[:event_id], params[:category]).first
  
        error!({ error: 'No available tickets' }, 404) unless ticket
  
        if ticket.booking&.expired?
          ticket.booking.destroy!
        elsif ticket.booking.present?
          error!({ error: 'Ticket was already booked' }, 400)
        end

        time_to_book = 5.minutes.from_now

        # Создаем бронь для билета
        booking = Booking.create!(
          ticket: ticket,
          expires_at: time_to_book
        )
  
        {
          reservation_id: booking.id,
          price: ticket.price,
          expires_at: booking.expires_at.iso8601
        }
      end
    end

    desc 'Get ticket information'
    params do
      requires :id, type: Integer, desc: 'Ticket ID'
    end
    
    get 'info/:id' do
      ticket = Ticket.find_by(id: params[:id])
      
      error!('Ticket not found', 404) unless ticket
      purchase = ticket.purchase
      error!('Purchase not found', 404) unless purchase
      
      {
        document_number: purchase.user_document,
        event_id: ticket.event_id,
        full_name: purchase.full_name,
        category: ticket.category,
        status: ticket.status
      }
    end

    desc 'Cancel booking by reservation_id'
      params do
        requires :id, type: Integer, desc: 'Reservation ID'
      end
      delete 'book/:id' do
        booking = Booking.find_by(id: params[:id])

        error!({ error: 'Booking not found' }, 404) unless booking

        if booking.expired?
          error!({ error: 'Booking already expired' }, 400)
        end

        booking.destroy!

        { status: 'cancelled' }
      end

      desc 'Block ticket for violation (ban)'
      params do
        requires :ticket_id, type: Integer, desc: 'Ticket ID'
        requires :document_number, type: String, desc: 'Violator\'s document'
      end
      post :block do
        ticket = Ticket.find_by(id: params[:ticket_id])
      
        error!({ error: 'Ticket not found' }, 404) unless ticket
        purchase = ticket.purchase
        error!('Purchase not found', 404) unless purchase
      
        if purchase.user_document != params[:document_number]
          error!({ error: 'Document does not match ticket holder' }, 403)
        end
      
        if ticket.blocked?
          error!({ error: 'Ticket already blocked' }, 400)
        end
      
        ticket.blocked!
      
        { blocked: true }
      end
  end
end