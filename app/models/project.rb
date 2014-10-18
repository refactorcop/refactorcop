# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  username    :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Project < ActiveRecord::Base
  validates :name, :username, presence: true, allow_blank: false
  validates_uniqueness_of :name, scope: :username

  def clone_url
    "git@github.com:#{username}/#{name}.git"
  end
end
