module MICROSERVICES
  TICKET_SERVICE       = ENV.fetch('TICKET_API_URL') { 'http://ticket-api:3000' }
  MAIN_SERVICE         = ENV.fetch('MAIN_API_URL') { 'http://main-api:3000' }
  ACCESS_CONTROL       = ENV.fetch('ACCESS_CONTROL_URL') { 'http://access-control:3000' }
end