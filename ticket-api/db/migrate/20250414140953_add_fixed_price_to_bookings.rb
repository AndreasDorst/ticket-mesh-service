class AddFixedPriceToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :fixed_price, :decimal, null: true
  end
end
