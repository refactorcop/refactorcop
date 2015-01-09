class AddOwnerAndPrivateRepositoryToProjects < ActiveRecord::Migration
  def change
    add_column :owner_id, :integer, index: true
    add_column :private_repository, :boolean, default: false
  end
end
