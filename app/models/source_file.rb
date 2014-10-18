# == Schema Information
#
# Table name: source_files
#
#  id               :integer          not null, primary key
#  project_id       :integer
#  content          :text
#  path             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class SourceFile < ActiveRecord::Base
  belongs_to :project
  has_many :rubocop_offenses, dependent: :destroy
  counter_culture :project

  def full_name
    path
  end

  def update_offenses
    rubocop_path = Rails.root.join(".rubocop.yml")
    Tempfile.open(['offenses', '.rb']) do |f|
      f.write(content.encode('utf-8'))
      f.read

      json_data = `bundle exec rubocop --config "#{rubocop_path}" -f json "#{f.path}"`
      json = MultiJson.load(json_data, symbolize_keys: true)
      json[:files].first[:offenses].each do |offense_json|
        self.rubocop_offenses.create({
          severity:   offense_json[:severity],
          message:    offense_json[:message],
          cop_name:   offense_json[:cop_name],
          location_column:  offense_json[:location][:column],
          location_line:    offense_json[:location][:line],
          location_length:  offense_json[:location][:length],
        })
      end
    end
    save!
  end
end
