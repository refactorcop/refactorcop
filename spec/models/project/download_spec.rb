require 'rails_helper'

RSpec.describe Project::Download do
  describe '.call' do
    let(:project) { create(:project, username: 'snusnu', name: 'procto') }
    it 'downloads the source code files' do
      results = described_class.call(project)
      expect(results.size).to eq 4
      expect(results.map(&:path).sort).to eq([
        "lib/procto.rb",
        "lib/procto/version.rb",
        "spec/procto_spec.rb",
        "spec/spec_helper.rb",
      ])
    end
  end
end
