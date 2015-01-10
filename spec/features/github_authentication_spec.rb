require 'rails_helper'
require 'capybara/rails'

RSpec.feature 'Github authetication', type: :feature do
  background do
    visit root_path
  end

  context 'when authentication succeed' do
    background do
      OmniAuth.config.add_mock(:github, {
        uid: '12345',
        info: { email: 'user@github.com' },
        credentials: { token: 'sample-token' }
      })
    end

    scenario 'when user already exists' do
      create(:user, github_uid: '12345', github_token: 'sample-token')

      expect do
        click_link 'Sign in with Github'
      end.to change{User.count}.by(0)
    end

    scenario 'when user authenticate for the first time' do
      click_link 'Sign in with Github'

      last_user = User.last
      expect(current_path).to eq(projects_path)
      expect(last_user.github_uid).to eq('12345')
      expect(last_user.github_token).to eq('sample-token')
      expect(last_user.email).to eq('user@github.com')
    end
  end

  scenario 'when authentication fails' do
    OmniAuth.config.mock_auth[:github] = :invalid_credentials

    VCR.use_cassette('github_auth_failure') do
      click_link 'Sign in with Github'
    end

    expect(current_path).to eq root_path
    expect(page).to have_text('We failed to authenticate with your Github account')
  end
end
