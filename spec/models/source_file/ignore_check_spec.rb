require 'procto'
require_relative '../../../app/models/source_file/ignore_check'

RSpec.describe SourceFile::IgnoreCheck do
  describe '.call' do
    subject { described_class.call(filename) }

    [
      'app/my_class.rb', false,
      'random_dir/code_spec.rb', true,
      'spec/spec_helper.rb', true,
      'Library/Formula/ap.rb', true,
      'activerecord/lib/rails/generators/active_record/model/templates/model.rb', true,
      'db/migrate/001_some_stuff.rb', true,
      'db/schema.rb', true,
      'lib/generators/templates/controllers/registrations_controller.rb', true,
      'lib/generators/active_record/controllers/registrations_controller.rb', true,
      'test/rails_app/app/active_record/admin.rb', true,
    ].each_slice(2) do |(name, result)|
      context "when filename is #{name.inspect}" do
        let(:filename) { name }
        it { is_expected.to eq result }
      end
    end

  end
end
