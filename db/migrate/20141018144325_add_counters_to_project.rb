class AddCountersToProject < ActiveRecord::Migration
  def change
    add_column :projects, :source_files_count, :integer, :null => false, :default => 0
    add_column :projects, :rubocop_offenses_count, :integer, :null => false, :default => 0
  end
end
