class AddIndexesToRubocopOffenses < ActiveRecord::Migration
  def change
    add_index :rubocop_offenses, :source_file_id
    add_index :rubocop_offenses, :severity
    add_index :rubocop_offenses, :cop_name
  end
end
