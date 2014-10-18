# == Schema Information
#
# Table name: source_files
#
#  id               :integer          not null, primary key
#  project_id       :integer
#  content          :text
#  path             :string(255)
#  rubocop_offenses :json
#  created_at       :datetime
#  updated_at       :datetime
#

class SourceFile < ActiveRecord::Base
  belongs_to :project
  counter_culture :project

  def full_name
    path
  end

  def update_offenses
    Tempfile.open(['offenses', '.rb']) do |f|
      f.write(sf.content.encode('utf-8'))
      json_data = `bundle exec rubocop --config ".rubocop.yml" -f json "#{f.path}"`
      sf.rubocop_offenses = json_data
    end
    sf.save!
  end
end
