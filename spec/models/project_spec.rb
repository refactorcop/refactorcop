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

  describe '#download_zip_url' do
    let(:project) { build(:private_project) }

    it 'must get archive url from github api' do
      VCR.use_cassette('github_archive_url') do
        download_url = project.download_zip_url
        expect(download_url).to eq('https://codeload.github.com/mperham/sidekiq/legacy.zip/master?token=AAKdasQlzV==')
      end
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

  describe '#write_files_to_dir' do
    let(:project) { create(:project) }
    it "saves its source files in the directory" do
      tmp_dir = Dir.mktmpdir
      project.source_files << create(:source_file, path: 'hello.rb', content: '# Hello')
      project.source_files << create(:source_file, path: 'hello/world.rb', content: '# World!')
      project.write_files_to_dir(tmp_dir)

      ruby_glob = File.join(tmp_dir, '**', '*.rb')
      absolute_paths = Dir.glob(ruby_glob).sort
      relative_paths = absolute_paths.map { |path| path.gsub(tmp_dir, '') }
      expect(relative_paths).to eq(['/hello.rb', '/hello/world.rb'])
      expect(File.read(absolute_paths[0])).to eq('# Hello')
      expect(File.read(absolute_paths[1])).to eq('# World!')
    end
  end

  describe '.find_by_full_name_and_owner' do
    [
      ['UserName', 'Name', 'username', 'name'],
      ['username', 'name', 'uSernAme', 'nAme'],
      ['username', 'name', 'username', 'name'],
    ].each do |(username, name, query_username, query_name)|
      context "when the project is '#{username}/#{name}' and the query uses '#{query_username}' and '#{query_name}'" do
        subject { described_class.find_by_full_name_and_owner(username, name) }
        let!(:project) { create(:project, username: username, name: name) }
        it { is_expected.to eq project  }
      end
    end

    context 'when owner is present and project have same owner' do
      subject { described_class.find_by_full_name_and_owner(username, name, user) }
      let(:username) { 'rails' }
      let(:name) { 'rails-private' }
      let(:user) { create(:user) }
      let!(:project) { create(:project, username: username, name: name, owner: user) }
      it { is_expected.to eq project  }
    end

    context 'when owner is present and project have other user has owner' do
      subject { described_class.find_by_full_name_and_owner(username, name, user) }
      let(:username) { 'rails' }
      let(:name) { 'rails-private' }
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let!(:project) { create(:project, username: username, name: name, owner: other_user) }
      it { is_expected.to be_nil }
    end

    context 'when owner is present and project dont have owner' do
      subject { described_class.find_by_full_name_and_owner(username, name, user) }
      let(:username) { 'rails' }
      let(:name) { 'rails' }
      let(:user) { create(:user) }
      let!(:project) { create(:project, username: username, name: name) }
      it { is_expected.to eq project  }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:source_files) }
    it { is_expected.to belong_to(:owner) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:username, :owner_id) }
  end
end
