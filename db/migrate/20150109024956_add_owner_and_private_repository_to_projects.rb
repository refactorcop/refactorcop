class AddOwnerAndPrivateRepositoryToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :owner_id, :integer, index: true
    add_column :projects, :private_repository, :boolean, default: false
  end
end
