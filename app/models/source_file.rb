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

end
