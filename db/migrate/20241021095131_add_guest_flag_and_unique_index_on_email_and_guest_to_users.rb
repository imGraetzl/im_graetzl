class AddGuestFlagAndUniqueIndexOnEmailAndGuestToUsers < ActiveRecord::Migration[6.1]
  def change
    # Füge die Spalte guest hinzu, aber nur, wenn sie noch nicht existiert
    unless column_exists?(:users, :guest)
      add_column :users, :guest, :boolean, default: false
    end

    # Entferne den bestehenden unique index auf die E-Mail-Spalte
    if index_exists?(:users, :email, unique: true)
      remove_index :users, :email
    end

    # Füge den kombinierten Index auf die Felder :email und :guest hinzu
    add_index :users, [:email, :guest], unique: true
  end
end
