require 'faraday'
require 'nokogiri'
require 'vcr'
require_relative '../../app/models/github_trending'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
end

describe GithubTrending do
  let(:gh) { described_class.new('ruby') }

  around(:each) do |example|
    VCR.use_cassette('github_trending') do
      example.run
    end
  end

  describe '#repositories' do
    subject { gh.repositories }
    it { is_expected.to be_a(Array) }
    it 'parses projects as GithubTrending::Project objects' do
      project = subject.first
      expect(project).to be_a GithubTrending::Project
      expect(project.name).to eq 'lewsnetter'
      expect(project.username).to eq 'bborn'
      expect(project.github_path).to eq '/bborn/lewsnetter'
      expect(project.clone_url).to eq 'git@github.com:bborn/lewsnetter.git'
      expect(project.description).to eq """
      E-mail marketing application (create and send e-mail newsletter via SES). Includes subscription management, delivery, bounce and complaint notification, templates, and some stats.
      """.strip
    end
  end
end
