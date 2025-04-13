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

      desc 'Get calculated ticket price for given event and category'
      params do
        requires :event_id, type: Integer, desc: 'Event ID'
        requires :category, type: String, desc: 'Ticket category (e.g. base, vip)'
      end
      get :price do
        category = params[:category]
        event_id = params[:event_id]

        # Проверяем, что категория существует
        unless Ticket.categories.key?(category)
          error!({ error: "Unknown category: #{category}" }, 400)
        end

        # Проверяем, что event_id валидный
        if event_id < 0
          error!({ error: "Invalid event_id: #{event_id}" }, 400)
        end

        # Находим хотя бы один доступный билет для указанного event_id и category
        ticket = Ticket.available_for_booking(event_id, category).first

        # Если билетов нет, возвращаем ошибку
        unless ticket
          error!({ error: "No available tickets found for event_id: #{event_id} and category: #{category}" }, 404)
        end

        # Получаем базовую цену из найденного билета
        base_price = ticket.base_price

        # Вычисляем итоговую цену для билета
        price = Ticket.price_for_category(event_id, category, base_price)

        # Возвращаем результат
        { category: category, price: price }
      end

      desc 'Bulk create tickets for an event'
      params do
        requires :event_id, type: Integer, desc: 'Event ID'
        requires :base_tickets_count, type: Integer, desc: 'Number of base tickets to create'
        requires :vip_tickets_count, type: Integer, desc: 'Number of VIP tickets to create'
        requires :base_price, type: BigDecimal, desc: 'Base ticket price'
        requires :vip_price, type: BigDecimal, desc: 'VIP ticket price'
      end
      post :bulk_create do
        event_id = params[:event_id]
        base_count = params[:base_tickets_count]
        vip_count = params[:vip_tickets_count]
        base_price = params[:base_price]
        vip_price = params[:vip_price]
      
        Ticket.transaction do
          base_tickets = Array.new(base_count) do
            {
              event_id: event_id,
              category: Ticket.categories[:base],
              status: Ticket.statuses[:available],
              base_price: base_price,
              created_at: Time.current,
              updated_at: Time.current
            }
          end
      
          vip_tickets = Array.new(vip_count) do
            {
              event_id: event_id,
              category: Ticket.categories[:vip],
              status: Ticket.statuses[:available],
              base_price: vip_price,
              created_at: Time.current,
              updated_at: Time.current
            }
          end
      
          all_tickets = base_tickets + vip_tickets
          Ticket.insert_all!(all_tickets)
        end
        
        status 201
        {
          created: {
            base: base_count,
            vip: vip_count
          }
        }
      end
  end
end