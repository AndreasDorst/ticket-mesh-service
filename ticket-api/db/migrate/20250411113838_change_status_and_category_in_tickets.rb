class ChangeStatusAndCategoryInTickets < ActiveRecord::Migration[7.1]
  def change
    change_column :tickets, :status, :integer, using: 'status::integer'
    change_column :tickets, :category, :string
  end
end
