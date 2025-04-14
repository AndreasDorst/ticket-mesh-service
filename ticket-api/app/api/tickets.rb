class Tickets < Grape::API
  format :json
  prefix :api

  helpers UserHelper

  resource :ticket do    
    desc 'Book ticket by event_id and category'
    params do
      requires :event_id, type: Integer
      requires :category, type: String
    end
    post :book do
      event_id = params[:event_id]
      category = params[:category]

      error!({ error: "Unknown category" }, 400) unless Ticket.categories.key?(category)
      
      Ticket.transaction do
        # Ищем подходящий доступный билет
        ticket = Ticket.available_for_booking(event_id, category).first
        error!({ error: 'No available tickets' }, 404) unless ticket
  
        if ticket.booking&.expired?
          ticket.booking.destroy!
        elsif ticket.booking.present?
          error!({ error: 'Ticket was already booked' }, 400)
        end

        base_price = ticket.event.base_price
        price = Ticket.price_for_category(event_id, category, base_price)

        # Создаем бронь для билета
        booking = Booking.create!(
          ticket: ticket,
          expires_at: Booking.default_expiration,
          fixed_price: price
        )

  
        {
          reservation_id: booking.id,
          price: price,
          expires_at: booking.expires_at.iso8601
        }
      end
    end

    desc 'Get ticket information'
    params do
      requires :id, type: Integer, desc: 'Ticket ID'
    end
    get 'info/:id' do
      ticket = Ticket.includes(purchase: :user).find_by(id: params[:id])
      error!({ error: 'Ticket not found' }, 404) unless ticket
    
      purchase = ticket.purchase
      error!({ error: 'Purchase not found' }, 404) unless purchase
    
      user = purchase.user
      error!({ error: 'User not found' }, 404) unless user
    
      {
        document_number: user.document_number,
        event_id: ticket.event_id,
        full_name: user.full_name,
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

      if booking.ticket&.purchase.present?
        error!({ error: 'Ticket has already been purchased and cannot be cancelled' }, 400)
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
      ticket = Ticket.includes(purchase: :user).find_by(id: params[:ticket_id])
      error!({ error: 'Ticket not found' }, 404) unless ticket

      purchase = ticket.purchase
      error!('Purchase not found', 404) unless purchase

      user = purchase.user
      error!({ error: 'User not found' }, 404) unless user
    
      if user.document_number != params[:document_number]
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

      # Проверяем, что event_id валидный и существует в базе
      event = Event.find_by(id: event_id)
      error!({ error: "Invalid event_id: #{event_id}" }, 400) unless event

      # Находим хотя бы один доступный билет для указанного event_id и category
      ticket = Ticket.available_for_booking(event_id, category).first

      # Если билетов нет, возвращаем ошибку
      unless ticket
        error!({ error: "No available tickets found for event_id: #{event_id} and category: #{category}" }, 404)
      end

      # Получаем базовую цену из найденного ивента
      base_price = event.base_price

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
    post :bulk_create do # TODO: убрать это, временная штука!
      event_id = params[:event_id]
      base_count = params[:base_tickets_count]
      vip_count = params[:vip_tickets_count]
      base_price = params[:base_price]
      vip_price = params[:vip_price]
    
      Ticket.transaction do
        # Ищем событие с таким ID, если не находим, создаем новое с этим ID
        event = Event.find_by(id: event_id)
        
        unless event
          begin
            event = Event.create!(
              id: event_id,
              base_price: base_price,
              vip_price: vip_price,
              name: "Event ##{event_id}", # Пример наименование, можно изменить
              date: Time.current # Пример, можно уточнить дату
            )
          rescue ActiveRecord::RecordInvalid => e
            error!({ error: "Event creation failed: #{e.message}" }, 400)
          end
        end
      
        # Теперь создаем билеты
        base_tickets = Array.new(base_count) do
          {
            event_id: event_id,
            category: Ticket.categories[:base],
            status: Ticket.statuses[:available],
            created_at: Time.current,
            updated_at: Time.current
          }
        end
      
        vip_tickets = Array.new(vip_count) do
          {
            event_id: event_id,
            category: Ticket.categories[:vip],
            status: Ticket.statuses[:available],
            created_at: Time.current,
            updated_at: Time.current
          }
        end
      
        all_tickets = base_tickets + vip_tickets
        Ticket.insert_all!(all_tickets)
      end

      Rails.logger.info("Bulk creation of #{base_count} base tickets and #{vip_count} VIP tickets for event #{event_id}")
      
      status 201
      {
        created: {
          base: base_count,
          vip: vip_count
        }
      }
    end

    desc 'Purchase a ticket by reservation_id and user_id'
    params do
      requires :reservation_id, type: Integer, desc: 'Reservation ID'
      requires :user_id, type: Integer, desc: 'User ID'
    end
    post :purchase do
      reservation_id = params[:reservation_id]
      user_id = params[:user_id]
    
      booking = Booking.find_by(id: reservation_id)
      error!({ error: 'Booking not found' }, 404) unless booking
      error!({ error: 'Booking has expired' }, 400) if booking.expired?
    
      ticket = booking.ticket
      price = booking.fixed_price
    
      existing_purchase = ticket.purchase
      if existing_purchase
        error!({ error: 'Ticket has already been purchased' }, 400)
      end
    
      user = User.find_by(id: user_id)
    
      unless user
        remote_user = get_user!(user_id) # ← основной вызов main-api
        # создаём локального юзера
        begin
          user = User.create!(
            id: user_id,
            full_name: remote_user['full_name'],
            document_number: remote_user['document_number']
          )
        rescue ActiveRecord::RecordInvalid => e
          error!({ error: 'Failed to save user locally', details: e.message }, 400)
        end
      end
    
      Purchase.transaction do
        purchase = Purchase.new(
          ticket: ticket,
          user_id: user.id
        )
    
        if purchase.save
          ticket.sold!
          { ticket_id: ticket.id, price: price }
        else
          error!({ error: 'Validation failed', details: purchase.errors.full_messages }, 400)
        end
      end
    end
  end
end