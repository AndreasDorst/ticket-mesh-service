class AddNotNullConstraintToTicketsEventId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tickets, :event_id, false
  end
end
