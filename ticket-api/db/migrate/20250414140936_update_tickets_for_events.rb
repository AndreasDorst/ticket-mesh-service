class UpdateTicketsForEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :tickets, :event_date, :date
    remove_column :tickets, :base_price, :decimal
    remove_column :tickets, :event_id, :integer # Удаляем старый event_id

    add_reference :tickets, :event, foreign_key: true
  end
end
