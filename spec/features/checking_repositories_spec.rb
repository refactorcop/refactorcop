require 'rails_helper'

RSpec.feature "Checking repositories", :type => :feature do
  let(:user) { create(:user) }

  scenario "Visiting an indexed repository" do
    create(:project, username: "Homebrew", name: "homebrew")
    visit "/homebrew/homebrew"
    expect(page.find(".project_details")).to have_content("homebrew / homebrew")
  end

  scenario 'Visiting indexed private respository and not authenticate with github' do
    VCR.use_cassette('github_private_project_without_token') do
      create(:private_project, username: "raphaelcosta", name: "sample-private")
      visit 'rails/private'
      expect(page).to have_text("We couldn't find your project")
    end
  end

  scenario "Visiting a repository with dots in its name" do
    create(:project, username: "github", name: "developer.github.com")
    visit "/github/developer.github.com"
    expect(page.find(".project_details")).to have_content("github / developer.github.com")
  end

  scenario "Visiting a project that hasn't been added yet" do
    VCR.use_cassette('github_project_pages', record: :new_episodes) do
      visit "/snusnu/procto"
      expect(page).to have_content("This project is freshly added, we don't have any results yet.")
    end
  end

  scenario "Visiting a private project that hasn't been added yet" do
    sign_in_as user

    VCR.use_cassette('github_add_private_repository') do
      visit "/raphaelcosta/sample-private"
      expect(page).to have_content("This project is freshly added, we don't have any results yet.")

      last_project = Project.last
      expect(last_project.name).to eq('sample-private')
      expect(last_project.private_repository).to eq(true)
      expect(last_project.owner).to eq(user)
    end
  end

  scenario "Adding project with encoded uri strips the part after the '?' sign" do
    VCR.use_cassette('github_project_pages', record: :new_episodes) do
      visit "/snusnu/procto#{CGI.escape('?page=15&severity=')}"
      expect(page).to have_content("snusnu / procto")
      expect(page).to_not have_content("snusnu / procto?page=15&severity=")
      expect(page).to have_content("This project is freshly added, we don't have any results yet.")
    end
  end

  scenario "Visiting a non-existing repository" do
    VCR.use_cassette('github_project_pages', record: :new_episodes) do
      visit "/this_repo/does_not_exist"
      expect(page).to have_content("We couldn't find your project")
      expect(page).to have_content("Import from github")
    end
  end

  scenario "Checking my synced private repositories" do
    sign_in_as user
    create(:private_project, username: 'rails', name: 'top-secret', owner: user)
    visit '/projects'

    expect(page).to have_text('rails / top-secret')
    expect(page).to have_text("Import from github")
  end

  private

  def sign_in_as(user)
    OmniAuth.config.add_mock(:github, {
      uid: user.github_uid,
      info: { email: user.email },
      credentials: { token: user.github_token }
    })

    visit root_path
    click_link 'Sign in with Github'
  end
end
