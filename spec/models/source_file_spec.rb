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

require 'rails_helper'

RSpec.describe SourceFile, :type => :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:rubocop_offenses).dependent(:destroy) }
  end
end
