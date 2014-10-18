require 'rails_helper'

RSpec.describe RubocopOffense, :type => :model do
  it { is_expected.to belong_to(:source_file) }
  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:cop_name) }
    it { is_expected.to validate_presence_of(:severity) }
  end
end
