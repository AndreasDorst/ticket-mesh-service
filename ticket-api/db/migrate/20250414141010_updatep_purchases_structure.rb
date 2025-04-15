class UpdatepPurchasesStructure < ActiveRecord::Migration[7.1]
  def change
    remove_column :purchases, :user_document, :string
    remove_column :purchases, :full_name, :string
    remove_column :purchases, :timestamp, :datetime
    remove_column :purchases, :user_id

    add_reference :purchases, :user, null: false, foreign_key: true, type: :bigint
    add_column :purchases, :purchased_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
