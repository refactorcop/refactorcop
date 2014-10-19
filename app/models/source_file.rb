# == Schema Information
#
# Table name: source_files
#
#  id         :integer          not null, primary key
#  project_id :integer
#  content    :text
#  path       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SourceFile < ActiveRecord::Base
  belongs_to :project
  has_many :rubocop_offenses, dependent: :destroy

  def full_name
    path
  end

end
