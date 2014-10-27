# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  username               :string(255)
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#  repository_data        :json
#  source_files_count     :integer          default(0), not null
#  rubocop_offenses_count :integer          default(0), not null
#  rubocop_run_started_at :datetime
#  rubocop_last_run_at    :datetime
#

require 'rails_helper'

RSpec.describe Project, :type => :model do
  let(:project) { build(:project) }

  around(:each) do |example|
    VCR.use_cassette('github_repository') do
      example.run
    end
  end

  describe '#clone_url' do
    subject { build(:project, username: 'tarantino', name: 'pulp-fiction').clone_url }
    it { is_expected.to eq 'git@github.com:tarantino/pulp-fiction.git' }
  end

  describe '#fetch_github_repository_data' do
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
      before :each do
        allow(project).to receive(:fetch_github_repository_data).and_return(nil)
      end
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

  describe '.find_by_full_name' do
    [
      ['UserName', 'Name', 'username', 'name'],
      ['username', 'name', 'uSernAme', 'nAme'],
      ['username', 'name', 'username', 'name'],
    ].each do |(username, name, query_username, query_name)|
      context "when the project is '#{username}/#{name}' and the query uses '#{query_username}' and '#{query_name}'" do
        subject { described_class.find_by_full_name(username, name) }
        let!(:project) { create(:project, username: username, name: name) }
        it { is_expected.to eq project  }
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:source_files) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:username) }
  end
end
