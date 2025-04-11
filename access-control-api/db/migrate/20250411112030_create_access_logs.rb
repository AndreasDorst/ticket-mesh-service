class CreateAccessLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :access_logs do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :status
      t.datetime :check_time

      t.timestamps
    end
  end
end
