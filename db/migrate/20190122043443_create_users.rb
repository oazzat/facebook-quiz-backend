class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :current_city
      t.string :hometown
      t.string :address
      t.string :birthday
      t.string :quote

      t.timestamps
    end
  end
end
