require 'rails_helper'

RSpec.describe ProjectDetails do
  let(:project_details) { described_class.new(username: username, name: name) }
  let(:username) { 'Homebrew' }
  let(:name) { 'homebrew' }

  describe '#project' do
    subject { project_details.project }
    let(:project) { double() }

    it 'finds the project by full name' do
      expect(Project).to receive(:find_by_full_name_and_owner).with(username, name, nil) { project }
      expect(subject).to eq(project)
    end
  end

  describe '#cache_key' do
    subject(:cache_key) { project_details.cache_key }
    context "when not linted yet" do
      let!(:project) { create(:project, username: username, name: name) }
      it { is_expected.to eq 'Homebrew/homebrew__unlinted' }
    end
    context "when linted" do
      let(:run_at) { DateTime.now }
      let!(:project) { create(:project, username: username, name: name, rubocop_last_run_at: run_at) }
      it { is_expected.to eq "Homebrew/homebrew__#{run_at.strftime('%Y-%m-%d')}" }
    end
  end
end
