class CreateSourceFiles < ActiveRecord::Migration
  def change
    create_table :source_files do |t|
      t.references :project, index: true
      t.text :content
      t.string :path
      t.json :rubocop_offenses

      t.timestamps
    end
  end
end
