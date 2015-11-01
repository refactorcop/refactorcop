class AddSeverityCountsToProjects < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.integer :fatal_count, default: 0
      t.integer :error_count, default: 0
      t.integer :warning_count, default: 0
      t.integer :convention_count, default: 0
      t.integer :refactor_count, default: 0
    end

    unless reverting?
      say_with_time "updating severity counts on #{Project.count} existing projects" do
        Project.all.find_each do |project|
          project.update_severity_counts
        end
      end
    end
  end
end
