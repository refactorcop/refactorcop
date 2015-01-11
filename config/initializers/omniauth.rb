Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENVied.GITHUB_KEY, ENVied.GITHUB_SECRET, scope: 'user:email,repo'
end
