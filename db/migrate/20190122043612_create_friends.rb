class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.string :name
      t.string :current_city
      t.string :hometown
      t.string :address
      t.string :birthday
      t.string :quote
      t.integer :user_id

      t.timestamps
    end
  end
end
