class RenameEventToEventIdInTickets < ActiveRecord::Migration[7.1]
  def change
    remove_column :tickets, :event, :string
    add_column :tickets, :event_id, :integer
    add_index :tickets, :event_id
  end
end
