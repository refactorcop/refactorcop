require 'rails_helper'

RSpec.describe Project::RubocopRun do
  let(:rubocop_run) { described_class.new(project) }
  let(:project) { create(:project) }

  it "stores the rubocop offenses in the database" do
    project.source_files << create(:source_file, {
      path: "something.rb",
      content: "class something \nend"
    })

    expect { rubocop_run.run }.to change { RubocopOffense.count }.by(1)

    offense = RubocopOffense.first
    expect(offense.message).to eq "class or module name must be a constant literal"
    expect(offense.project).to eq project
  end
end
