class AddRubocopRunTimestampToProject < ActiveRecord::Migration
  def change
    add_column :project, :rubocop_run_started_at, :integer, default: 0, null: false
    add_column :project, :rubocop_run_dispatched_at, :integer, default: 0, null: false
  end
end
