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

require 'rails_helper'

RSpec.describe RubocopOffense, :type => :model do
  it { is_expected.to belong_to(:source_file) }
  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:cop_name) }
    it { is_expected.to validate_presence_of(:severity) }
  end
end
