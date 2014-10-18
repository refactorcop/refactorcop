# == Schema Information
#
# Table name: projects
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  username        :string(255)
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#  repository_data :json
#

require 'rails_helper'

RSpec.describe Project, :type => :model do
  describe '#clone_url' do
    subject { build(:project, username: 'tarantino', name: 'pulp-fiction').clone_url }
    it { is_expected.to eq 'git@github.com:tarantino/pulp-fiction.git' }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:username) }
  end
end
