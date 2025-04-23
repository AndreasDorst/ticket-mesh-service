class AddExternalToAccessLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :access_logs, :external, :string
    add_index :access_logs, :external, unique: true
  end
end
