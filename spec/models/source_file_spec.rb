# == Schema Information
#
# Table name: source_files
#
#  id         :integer          not null, primary key
#  project_id :integer
#  content    :text
#  path       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe SourceFile, :type => :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:rubocop_offenses).dependent(:destroy) }
  end

  describe '#update_offenses' do
    let :source_file do
      source_file = build(:source_file)
      source_file.content = """
class STUFF
  def Hello_worlD(a)
    if a == 1
      if a % $b
      end
      return ''
    elsif a >= 2
      x = SecureRandom.random_number(1000)
      return SecureRandom.random_number(1000)
    end

    if a == 3
      if a % $b
      end
      return ''
    elsif a >= 2
    end
  end

  def bye_world(a)
    if a == 1
      if a % $b
      end
      return ''
    elsif a >= 2
      x = SecureRandom.random_number(1000)
      return SecureRandom.random_number(1000)
    end

    if a == 3
      if a % $b
      end
      return ''
    elsif a >= 2
    end
  end
end
      """.strip
      source_file.save!
      source_file
    end

    it do
      source_file.update_offenses
      expect(source_file.rubocop_offenses.map(&:cop_name).sort).to eq([
        "Lint/UselessAssignment", "Lint/UselessAssignment",
        "Metrics/CyclomaticComplexity", "Metrics/CyclomaticComplexity",
        "Metrics/MethodLength", "Metrics/MethodLength",
        "Metrics/PerceivedComplexity", "Metrics/PerceivedComplexity"
      ])
      expect(source_file.rubocop_offenses.count).to eq 8
    end
  end
end
