class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :mp_key
      t.integer :athlete_id
      t.integer :expires_at
      t.string :refresh_token
      t.string :access_token
      t.timestamps
    end
    add_index :users, :athlete_id
  end
end
