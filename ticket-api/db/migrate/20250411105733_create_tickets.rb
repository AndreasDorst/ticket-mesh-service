class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.integer :category
      t.string :status
      t.decimal :price
      t.string :event
      t.date :event_date
      t.decimal :base_price
      t.integer :sold_percentage

      t.timestamps
    end
  end
end
