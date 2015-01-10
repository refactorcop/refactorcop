class AddIndexToProjectOwnerId < ActiveRecord::Migration
  def change
    add_index :projects, :owner_id
  end
end
