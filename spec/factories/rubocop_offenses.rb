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
