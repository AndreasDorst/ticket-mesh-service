class CreateBlockedTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :blocked_tickets do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :document_number, limit: 50

      t.timestamps
    end
  end
end
