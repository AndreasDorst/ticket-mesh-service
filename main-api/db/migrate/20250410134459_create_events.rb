class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :event_name
      t.date :event_date
      t.integer :base_tickets_amount
      t.integer :vip_tickets_amount
      t.float :base_ticket_price
      t.float :vip_ticket_price

      t.timestamps
    end
  end
end
