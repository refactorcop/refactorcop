require 'rails_helper'

RSpec.describe GithubProject do
  let(:gh_project) { described_class.new(username: username, name: name) }

  around :each do |example|
    VCR.use_cassette("github_project_pages", record: :new_episodes) do
      example.run
    end
  end

  describe '#exists?' do
    subject { gh_project.exists? }

    context "when the project exists" do
      let(:username) { 'rails' }
      let(:name) { 'rails' }
      it { is_expected.to eq true }
    end

    context "when the project doesn't exist" do
      let(:username) { 'rails' }
      let(:name) { 'rails-enterprise-edition' }
      it { is_expected.to eq false }
    end
  end

  describe '#to_project' do
    subject(:project) { gh_project.to_project }

    context "when the project exists" do
      let(:username) { 'rails' }
      let(:name) { 'rails' }
      it { is_expected.to be_a Project }
      it "sets name, username and description" do
        expect(project.name).to eq 'rails'
        expect(project.username).to eq 'rails'
        expect(project.description).to eq 'Ruby on Rails'
        expect(project.persisted?).to eq false
      end
    end

    context "when the project doesn't exist" do
      let(:username) { 'rails' }
      let(:name) { 'rails-enterprise-edition' }
      it { is_expected.to eq nil }
    end
  end
end
