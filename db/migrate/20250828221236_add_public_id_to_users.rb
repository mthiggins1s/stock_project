class AddPublicIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :public_id, :string, null: false, default: -> { "gen_random_uuid()" }
    add_index :users, :public_id, unique: true
  end
end
