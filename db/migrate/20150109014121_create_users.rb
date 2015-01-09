class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :github_uid
      t.string :github_token

      t.timestamps
    end
    add_index :users, :github_uid
  end
end
