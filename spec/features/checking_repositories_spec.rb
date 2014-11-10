require 'rails_helper'
require 'capybara/rails'

RSpec.feature "Checking repositories", :type => :feature do
  scenario "Visiting an indexed repository" do
    create(:project, username: "Homebrew", name: "homebrew")
    visit "/homebrew/homebrew"
    expect(page.find(".project_details")).to have_content("homebrew / homebrew")
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

  scenario "Adding project with encoded uri strips the part after the '?' sign" do
    VCR.use_cassette('github_project_pages', record: :new_episodes) do
      visit "/snusnu/procto#{CGI.escape('?page=15&severity=')}"
      expect(page).to have_content("snusnu / procto")
      expect(page).to_not have_content("snusnu / procto?page=15&severity=")
      expect(page).to have_content("This project is freshly added, we don't have any results yet.")
    end
  end
end
