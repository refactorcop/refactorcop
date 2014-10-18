class AddRepositoryDataToProjects < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.json :repository_data
    end
  end
end
