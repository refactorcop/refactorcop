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
  let(:project) { build(:project) }

  describe '#clone_url' do
    subject { build(:project, username: 'tarantino', name: 'pulp-fiction').clone_url }
    it { is_expected.to eq 'git@github.com:tarantino/pulp-fiction.git' }
  end

  describe '#fetch_github_repository_data' do
    around(:each) do |example|
      VCR.use_cassette('github_repository') do
        example.run
      end
    end
    subject { project.fetch_github_repository_data }
    let(:project) { build(:project, username: 'mperham', name: 'sidekiq') }

    it 'returns the repository data' do
      expect(DateTime.parse(subject[:pushed_at])).to eq(DateTime.parse("2014-10-16T21:07:30Z"))
      expect(subject[:ssh_url]).to eq("git@github.com:mperham/sidekiq.git")
    end
  end

  describe '#pushed_at' do
    subject { project.pushed_at }

    context 'when no repository data' do
      let(:project) { build(:project, repository_data: nil) }
      it { is_expected.to be < 99.years.ago }
    end

    context 'when repository data' do
      let(:project) { create(:project, repository_data: {pushed_at: pushed_at}) }
      let(:pushed_at) { DateTime.now.utc }

      it do
        expect(subject.httpdate).to eq pushed_at.httpdate
      end
    end
  end

  describe '#default_branch' do
    subject { project.default_branch }
    let(:project) { create(:project, repository_data: {default_branch: "stable"}) }
    it { is_expected.to eq "stable" }
  end

  describe '#update_source_files!' do
    let(:source_file) { double() }
    let(:source_files) { [source_file] }

    before :each do
      allow_any_instance_of(Project::Download).to receive(:call).and_return(source_files)
    end

    it 'downloads and saves each file' do
      expect(source_file).to receive(:save!)
      project.update_source_files!
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:username) }
  end
end
