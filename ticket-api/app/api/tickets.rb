class Tickets < Grape::API
  format :json
  prefix :api

  helpers UserHelper

  helpers do
    def find_event!(event_id)
      Event.find_by(id: event_id) || error!({ error: "Invalid event_id: #{event_id}" }, 400)
    end

    def find_ticket!(ticket_id)
      Ticket.includes(purchase: :user).find_by(id: ticket_id) || error!({ error: 'Ticket not found' }, 404)
    end

    def find_booking!(id)
      Booking.find_by(id: id) || error!({ error: 'Booking not found' }, 404)
    end

    def validate_category!(category)
      error!({ error: "Unknown category" }, 400) unless Ticket.categories.key?(category)
    end

    def fetch_available_ticket(event_id, category)
      Ticket.available_for_booking(event_id, category).first
    end
  end

  resource :ticket do
    desc 'Book ticket by event_id and category'
    params do
      requires :event_id, type: Integer
      requires :category, type: String
    end
    post :book do
      validate_category!(params[:category])

      Ticket.transaction do
        ticket = fetch_available_ticket(params[:event_id], params[:category])
        error!({ error: 'No available tickets' }, 404) unless ticket

        if ticket.booking&.expired?
          ticket.booking.destroy!
        elsif ticket.booking
          error!({ error: 'Ticket was already booked' }, 400)
        end

        price = Ticket.price_for_category(params[:event_id], params[:category], ticket.event.base_price)

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
    params { requires :id, type: Integer, desc: 'Ticket ID' }
    get 'info/:id' do
      ticket = find_ticket!(params[:id])
      purchase = ticket.purchase || error!({ error: 'Purchase not found' }, 404)
      user = purchase.user || error!({ error: 'User not found' }, 404)

      {
        document_number: user.document_number,
        event_id: ticket.event_id,
        full_name: user.full_name,
        category: ticket.category,
        status: ticket.status
      }
    end

    desc 'Cancel booking by reservation_id'
    params { requires :id, type: Integer, desc: 'Reservation ID' }
    delete 'book/:id' do
      booking = find_booking!(params[:id])

      error!({ error: 'Booking already expired' }, 400) if booking.expired?
      error!({ error: 'Ticket has already been purchased' }, 400) if booking.ticket&.purchase.present?

      booking.destroy!
      { status: 'cancelled' }
    end

    desc 'Block ticket for violation (ban)'
    params do
      requires :ticket_id, type: Integer
      requires :document_number, type: String
    end
    post :block do
      ticket = find_ticket!(params[:ticket_id])
      purchase = ticket.purchase || error!({ error: 'Purchase not found' }, 404)
      user = purchase.user || error!({ error: 'User not found' }, 404)

      error!({ error: 'Document does not match ticket holder' }, 403) if user.document_number != params[:document_number]
      error!({ error: 'Ticket already blocked' }, 400) if ticket.blocked?

      ticket.blocked!
      { blocked: true }
    end

    desc 'Get calculated ticket price for given event and category'
    params do
      requires :event_id, type: Integer
      requires :category, type: String
    end
    get :price do
      validate_category!(params[:category])
      event = find_event!(params[:event_id])
      ticket = fetch_available_ticket(params[:event_id], params[:category])

      error!({ error: "No available tickets found for event_id: #{params[:event_id]} and category: #{params[:category]}" }, 404) unless ticket

      price = Ticket.price_for_category(params[:event_id], params[:category], event.base_price)
      { category: params[:category], price: price }
    end

    desc 'Bulk create tickets for an event'
    params do
      requires :event_id, type: Integer
      requires :base_tickets_count, type: Integer
      requires :vip_tickets_count, type: Integer
      requires :base_price, type: BigDecimal
      requires :vip_price, type: BigDecimal
    end
    post :bulk_create do
      Ticket.transaction do
        event = Event.find_or_create_by(id: params[:event_id]) do |e|
          e.base_price = params[:base_price]
          e.vip_price = params[:vip_price]
          e.name = "Event ##{params[:event_id]}"
          e.date = Time.current
        end

        tickets = []

        tickets += Array.new(params[:base_tickets_count]) do
          { event_id: event.id, category: Ticket.categories[:base], status: Ticket.statuses[:available], created_at: Time.current, updated_at: Time.current }
        end

        tickets += Array.new(params[:vip_tickets_count]) do
          { event_id: event.id, category: Ticket.categories[:vip], status: Ticket.statuses[:available], created_at: Time.current, updated_at: Time.current }
        end

        Ticket.insert_all!(tickets)
      end

      status 201
      {
        created: {
          base: params[:base_tickets_count],
          vip: params[:vip_tickets_count]
        }
      }
    end

    desc 'Purchase a ticket by reservation_id and user_id'
    params do
      requires :reservation_id, type: Integer
      requires :user_id, type: Integer
    end
    post :purchase do
      booking = find_booking!(params[:reservation_id])
      error!({ error: 'Booking has expired' }, 400) if booking.expired?

      ticket = booking.ticket
      price = booking.fixed_price

      error!({ error: 'Ticket has already been purchased' }, 400) if ticket.purchase.present?

      user = User.find_by(id: params[:user_id]) || begin
        remote_user = get_user!(params[:user_id])
        User.create!(
          id: params[:user_id],
          full_name: remote_user['full_name'],
          document_number: remote_user['document_number']
        )
      rescue ActiveRecord::RecordInvalid => e
        error!({ error: 'Failed to save user locally', details: e.message }, 400)
      end

      Purchase.transaction do
        purchase = Purchase.new(ticket: ticket, user_id: user.id)
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