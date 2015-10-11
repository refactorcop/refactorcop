require 'rails_helper'
require 'capybara/rails'

RSpec.feature "Checking repositories", :type => :feature do
  scenario "Visiting the home page" do
    visit "/"
    expect(page.find(".trending")).to have_text("Trending")
    expect(page.find(".recommended")).to have_text("Recommended")
  end

  scenario "Visiting an indexed repository" do
    create(:project, username: "Homebrew", name: "homebrew")
    visit "/homebrew/homebrew"
    expect(page.find(".project-details")).to have_content("homebrew / homebrew")
  end

  scenario "Visiting a repository with dots in its name" do
    create(:project, username: "github", name: "developer.github.com")
    visit "/github/developer.github.com"
    expect(page.find(".project-details")).to have_content("github / developer.github.com")
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

  scenario "Visiting a non-existing repository" do
    VCR.use_cassette('github_project_pages', record: :new_episodes) do
      visit "/this_repo/does_not_exist"
      expect(page).to have_content("We couldn't find your project")
      expect(page).to have_content("Import from github")
    end
  end
end
