require 'rails_helper'
require 'zip'
require 'fileutils'

RSpec.describe Project::ZipFile do
  describe '#ruby_entries' do
    it 'only returns the ruby files' do
      create_zip([
        '.rubocop_todo.yml',
        'README.md',
        File.join('lib', 'code.rb'),
      ]) do |zip_file|
        pzf = described_class.new(zip_file)
        expect(pzf.ruby_entries.map(&:name)).to match_array(['lib/code.rb'])
      end
    end
  end

  describe '#has_rubocop_todos?' do
    it "returns true if .rubocop_todo.yml present" do
      create_zip([
        '.rubocop_todo.yml',
        'README.md',
        File.join('lib', 'code.rb'),
      ]) do |zip_file|
        pzf = described_class.new(zip_file)
        expect(pzf.has_rubocop_todos?).to eq(true)
      end
    end

    it "returns false if .rubocop_todo.yml absent" do
      create_zip([
        'README.md',
        File.join('lib', 'code.rb'),
      ]) do |zip_file|
        pzf = described_class.new(zip_file)
        expect(pzf.has_rubocop_todos?).to eq(false)
      end
    end
  end

  def create_zip(filenames, dir: 'example_project')
    dir = Rails.root.join('spec', 'fixtures', dir)
    zip_path = "#{dir}.zip"
    FileUtils.rm_f(zip_path)

    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      filenames.each do |filename|
        zipfile.add(filename, File.join(dir, filename))
      end
    end

    File.open(zip_path) do |f|
      yield(f)
    end
  end
end
