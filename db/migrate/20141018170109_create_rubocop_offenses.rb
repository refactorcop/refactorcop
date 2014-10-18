class CreateRubocopOffenses < ActiveRecord::Migration
  def change
    create_table :rubocop_offenses do |t|
      t.string :severity, null: false
      t.string :message, null: false
      t.string :cop_name
      t.string :message
      t.integer :location_line
      t.integer :location_column
      t.integer :location_length

      t.belongs_to :source_file

      t.timestamps
    end
  end
end
