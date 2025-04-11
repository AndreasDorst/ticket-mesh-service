class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :user_id
      t.timestamp :timestamp

      t.timestamps
    end
  end
end
