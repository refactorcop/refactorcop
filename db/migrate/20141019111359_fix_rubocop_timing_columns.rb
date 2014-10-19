class FixRubocopTimingColumns < ActiveRecord::Migration
  def change
    remove_column :projects, :rubocop_run_started_at
    remove_column :projects, :rubocop_run_dispatched_at

    add_column :projects, :rubocop_run_started_at, :datetime
    add_column :projects, :rubocop_last_run_at, :datetime
  end
end
