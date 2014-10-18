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

require 'rails_helper'

RSpec.describe SourceFile, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
