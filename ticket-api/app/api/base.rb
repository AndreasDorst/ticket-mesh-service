class Base < Grape::API
  mount V1::Tickets
end