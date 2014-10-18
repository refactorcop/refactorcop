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

FactoryGirl.define do
  factory :rubocop_offense do
    severity "convention"
    message "MyString"
    cop_name "MyString"
    message "MyString"
    location_line 1
    location_column 1
    location_length 1
  end

end
