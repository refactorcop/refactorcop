# == Schema Information
#
# Table name: rubocop_offenses
#
#  id              :integer          not null, primary key
#  severity        :string(255)      not null
#  message         :text
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

  describe '#line_range' do
    [
      [3, 4, (0..3)],
      [5, 10, (1..7)],
      [10, 10, (6..9)],
    ].each do |(location, line_count, expected_range)|
      context "when the location_line is #{location} and the file counts #{line_count} lines" do
        subject { offense.line_range }
        let(:offense) { build(:rubocop_offense, location_line: location, source_file: source) }
        let(:source) { build(:source_file, content: content) }
        let(:content) { "abc\n" * line_count }
        it { is_expected.to eq expected_range }
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:cop_name) }
    it { is_expected.to validate_presence_of(:severity) }
  end
end
