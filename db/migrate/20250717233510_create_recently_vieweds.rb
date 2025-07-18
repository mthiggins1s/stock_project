class CreateRecentlyVieweds < ActiveRecord::Migration[8.0]
  def change
    create_table :recently_vieweds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.decimal :viewed_price

      t.timestamps
    end
  end
end
