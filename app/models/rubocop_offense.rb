# == Schema Information
#
# Table name: rubocop_offenses
#
#  id              :integer          not null, primary key
#  severity        :string(255)      not null
#  message         :string(255)
#  cop_name        :string(255)
#  location_line   :integer
#  location_column :integer
#  location_length :integer
#  source_file_id  :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class RubocopOffense < ActiveRecord::Base
  validates_presence_of :message, :cop_name, :severity
  belongs_to :source_file

  def line_range
    (location_line-1)..(location_line + location_length)
  end

  def github_link
    project = source_file.project

    #"https://github.com/expectedbehavior/acts_as_archival/blob/05dc4e5d6f621dcc76028d88699e0e7a178ff78c/lib/expected_behavior/acts_as_archival.rb#L2-L8"

    "https://github.com/" + [
      project.username,
      project.name,
      "blob",
      project.default_branch,
      source_file.path,
    ].join('/') + "#L#{location_line}"
  end
end
