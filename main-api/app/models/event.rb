class Event < ApplicationRecord
  validates :event_name, presence: true
  validates :event_date, presence: true
  validates :base_tickets_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :vip_tickets_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :base_ticket_price, numericality: { greater_than_or_equal_to: 0 }
  validates :vip_ticket_price, numericality: { greater_than_or_equal_to: 0 }

  # Callback для отправки запроса на создание билетов в Ticket Service после создания события
  after_create :create_tickets_in_ticket_service

  private

  # Метод для отправки запроса на создание билетов
  def create_tickets_in_ticket_service
    url = "#{MICROSERVICES::TICKET_SERVICE}/internal/ticket/bulk_create"
    headers = { 'Content-Type' => 'application/json' }
    body = {
      event_id: self.id,
      base_tickets_count: self.base_tickets_amount,
      vip_tickets_count: self.vip_tickets_amount
    }.to_json

    # Отправка POST запроса в Ticket Service
    response = Faraday.post(url, body, headers)

    if response.status != 201
      Rails.logger.error "Failed to create tickets for event #{self.id}: #{response.body}"
    end
  end
end
