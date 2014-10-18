class RemoveRubocopOffensesJsonFromSourceFile < ActiveRecord::Migration
  def change
    remove_column :source_files, :rubocop_offenses
  end
end
