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
    ].each_slice(2) do |(name, result)|
      context "when filename is #{name.inspect}" do
        let(:filename) { name }
        it { is_expected.to eq result }
      end
    end

  end
end
