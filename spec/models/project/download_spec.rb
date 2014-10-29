require 'rails_helper'

RSpec.describe Project::Download do
  let(:http_mock) { class_double("HTTPClient") }

  before :each do
    # Stub the downloading of the zip archive of a repository
    allow(http_mock).to receive(:get_content) { |_url, &block|
      path = Rails.root.join('spec', 'assets', 'procto-master.zip')
      file = File.open(path, 'r')
      block.call(file.read)
    }
  end

  around :each do |example|
    VCR.use_cassette('github_repository') do
      example.run
    end
  end

  describe '.call' do
    let(:project) { create(:project, username: 'snusnu', name: 'procto') }

    it 'downloads the source code files' do
      expect {
        described_class.call(project, http_client: http_mock)
      }.to change { SourceFile.count }.by 2
      expect(SourceFile.all.map(&:path).sort).to eq([
        "lib/procto.rb",
        "lib/procto/version.rb",
      ])
    end
  end
end
