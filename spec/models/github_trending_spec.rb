require 'rails_helper'

RSpec.describe GithubTrending do
  let(:gh) { described_class.new('ruby') }

  around(:each) do |example|
    VCR.use_cassette('github_trending') do
      example.run
    end
  end

  describe '#projects' do
    subject { gh.projects }
    it { is_expected.to be_a(Array) }
    it 'parses projects as Project objects' do
      project = subject.first
      expect(project).to be_a Project
      expect(project.name).to eq 'lewsnetter'
      expect(project.username).to eq 'bborn'
      expect(project.clone_url).to eq 'git@github.com:bborn/lewsnetter.git'
      expect(project.description).to eq """
      E-mail marketing application (create and send e-mail newsletter via SES). Includes subscription management, delivery, bounce and complaint notification, templates, and some stats.
      """.strip
    end
  end

  describe '#persist_projects' do
    subject { gh.persist_projects }

    it 'saves the projects' do
      project = instance_double("Project")
      expect(project).to receive(:save!)
      expect(gh).to receive(:projects).and_return [project]
      subject
    end
  end
end
