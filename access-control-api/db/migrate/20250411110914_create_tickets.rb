class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.integer :external_id
      t.integer :event_id
      t.string :full_name
      t.string :document_number
      t.string :category

      t.timestamps
    end
  end
end
