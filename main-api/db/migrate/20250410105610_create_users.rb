class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :full_name
      t.integer :age
      t.string :document_type
      t.string :document_number
      t.string :password_digest

      t.timestamps
    end
  end
end
