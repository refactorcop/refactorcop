require 'rails_helper'

RSpec.describe RubocopWorker do
  subject { described_class.new.perform(project_id) }

  context "when project doesn't exists" do
    let(:project_id) { 999999 }
    it "ignores that and exits" do
      expect(Project::DownloadAndLint).to_not receive(:call)
      subject
    end
  end

  context "when project exists" do
    let(:project_id) { create(:project).id }
    it "downloads and lints the project" do
      expect(Project::DownloadAndLint).to receive(:call)
      subject
    end
  end
end
