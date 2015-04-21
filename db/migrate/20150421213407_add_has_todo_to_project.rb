class AddHasTodoToProject < ActiveRecord::Migration
  def change
    add_column :projects, :has_todo, :boolean, null: false, default: false
  end
end
