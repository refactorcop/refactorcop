require 'rails_helper'

RSpec.describe ProjectDetails do
  let(:project_details) { described_class.new(username: username, name: name) }
  let(:username) { 'Homebrew' }
  let(:name) { 'homebrew' }

  describe '#project' do
    subject { project_details.project }
    let(:project) { double() }

    it 'finds the project by full name' do
      expect(Project).to receive(:find_by_full_name).with(username, name) { project }
      expect(subject).to eq(project)
    end
  end
end
