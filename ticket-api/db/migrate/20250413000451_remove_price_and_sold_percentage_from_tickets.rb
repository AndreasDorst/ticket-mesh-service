class RemovePriceAndSoldPercentageFromTickets < ActiveRecord::Migration[7.1]
  def change
    remove_column :tickets, :price, :decimal
    remove_column :tickets, :sold_percentage, :integer
  end
end
