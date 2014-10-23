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
end
