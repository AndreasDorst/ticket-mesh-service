class DropBlockedTickets < ActiveRecord::Migration[7.1]
  def change
    drop_table :blocked_tickets
  end
end
