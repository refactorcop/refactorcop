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

FactoryGirl.define do
  factory :source_file do
    project nil
    content "def hello"
    path "source_file.rb"
  end

end
