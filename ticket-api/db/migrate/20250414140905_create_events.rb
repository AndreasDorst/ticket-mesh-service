class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.date :date, null: false
      t.decimal :base_price, null: false
      t.decimal :vip_price, null: false

      t.timestamps
    end
  end
end
