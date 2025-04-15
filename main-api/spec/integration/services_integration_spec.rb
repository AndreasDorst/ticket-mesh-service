require 'rails_helper'
require 'httparty'

RSpec.describe 'Services Integration', type: :request do
  let(:default_headers) do
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def make_request(method, url, params = {})
    response = HTTParty.send(
      method,
      url,
      body: params.to_json,
      headers: default_headers
    )

    # Для удобства тестирования
    if !response.success?
      puts "\nRequest failed:"
    else
      puts "\nRequest succeeded:"
    end
    puts "URL: #{url}"
    puts "Params: #{params.to_json}"
    puts "Response code: #{response.code}"
    puts "Response body: #{response.body}"

    response
  end

  describe 'Full ticket lifecycle' do
    before(:all) { WebMock.allow_net_connect! }
    after(:all) { WebMock.disable_net_connect!(allow_localhost: true) }
    let(:document_type) { 'passport' }
    let(:document_number) { 'AB123456' }
    let(:full_name) { 'John Doe' }
    let(:age) { '30' }
    # В нашей системе (пока-что нет email'ов у user'ов)
    # let(:user_email) { 'test@example.com' }
    let(:user_password) { 'password123' }
    let(:event_params) do
      {
        event: {
          event_name: 'Test Event',
          event_date: '2025-05-01',
          base_tickets_amount: 80,
          vip_tickets_amount: 20,
          base_ticket_price: 1000.0,
          vip_ticket_price: 2000.0
        }
      }
    end

    it 'successfully handles event creation, ticket booking, ticket purchase, and access control' do
      # 1. Создание пользователя
      user_response = make_request(
        :post,
        "#{ENV['MAIN_API_URL']}/auth/register",
        {
          user: {
            full_name: full_name,
            age: age,
            document_type: document_type,
            document_number: document_number,
            password: user_password,
            password_confirmation: user_password,
            # email: user_email,
          }
        }
      )

      expect(user_response.code).to eq(201)
      user_data = JSON.parse(user_response.body)

      expect(user_data['user_id']).to be_present
      user_id = user_data['user_id']

      # 2. Создание события
      event_response = make_request(
        :post,
        "#{ENV['MAIN_API_URL']}/events",
        event_params
      )

      expect(event_response.code).to eq(200)
      event_data = JSON.parse(event_response.body)
      expect(event_data['event_id']).to be_present
      event_id = event_data['event_id']

      # 3. Бронирование билета
      booking_params = {
        event_id: event_id,
        category: 'vip'
      }

      booking_response = make_request(
        :post,
        "#{ENV['TICKET_API_URL']}/api/ticket/book",
        booking_params
      )

      expect(booking_response.code).to eq(201)
      booking_data = JSON.parse(booking_response.body)
      expect(booking_data['reservation_id']).to be_present
      reservation_id = booking_data['reservation_id']

      # 4. Покупка билета
      purchase_params = {
        reservation_id: reservation_id,
        user_id: user_id
      }

      purchase_response = make_request(
        :post,
        "#{ENV['TICKET_API_URL']}/api/ticket/purchase",
        purchase_params
      )

      expect(purchase_response.code).to eq(201)
      purchase_data = JSON.parse(purchase_response.body)
      expect(purchase_data['ticket_id']).to be_present
      ticket_id = purchase_data['ticket_id']

      # 5. Попытка входа
      entry_params = {
        ticket_id: ticket_id,
        document_number: document_number,
        full_name: full_name
      }

      entry_response = make_request(
        :post,
        "#{ENV['ACCESS_CONTROL_URL']}/api/access/entry",
        entry_params
      )

      expect(entry_response.code).to eq(200)
      entry_data = JSON.parse(entry_response.body)
      expect(entry_data['access_granted']).to be true
      expect(entry_data['log_id']).to be_present

      # 6. Попытка повторного входа
      reentry_response = make_request(
        :post,
        "#{ENV['ACCESS_CONTROL_URL']}/api/access/entry",
        entry_params
      )

      expect(reentry_response.code).to eq(409)
      expect(JSON.parse(reentry_response.body)['error']).to eq('Already inside')

      # 7. Выход
      exit_params = {
        ticket_id: ticket_id
      }

      exit_response = make_request(
        :post,
        "#{ENV['ACCESS_CONTROL_URL']}/api/access/exit",
        exit_params
      )

      expect(exit_response.code).to eq(200)
      exit_data = JSON.parse(exit_response.body)
      expect(exit_data['exit_registered']).to be true
      expect(exit_data['log_id']).to be_present
    end
  end
end