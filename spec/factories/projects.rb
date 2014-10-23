# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  username               :string(255)
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#  repository_data        :json
#  source_files_count     :integer          default(0), not null
#  rubocop_offenses_count :integer          default(0), not null
#  rubocop_run_started_at :datetime
#  rubocop_last_run_at    :datetime
#

FactoryGirl.define do
  factory :project do
    name "sidekiq"
    username "mperham"
    description "MyText"

    # Prevent triggering of request to GitHub
    repository_data({
      "pushed_at" => DateTime.now,
      "default_branch" => "master"
    })
  end
end
