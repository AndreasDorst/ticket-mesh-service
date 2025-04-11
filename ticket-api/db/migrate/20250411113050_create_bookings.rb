class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :ticket, null: false, foreign_key: true
      t.timestamp :expires_at
      t.string :user_document, limit: 50

      t.timestamps
    end
  end
end
