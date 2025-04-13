class MoveUserDocumentToPurchases < ActiveRecord::Migration[7.1]
  def change
        # Удаляем user_document из bookings
        remove_column :bookings, :user_document, :string, limit: 50

        # Добавляем user_document и full_name в purchases
        add_column :purchases, :user_document, :string, limit: 50
        add_column :purchases, :full_name, :string, limit: 100
  end
end
