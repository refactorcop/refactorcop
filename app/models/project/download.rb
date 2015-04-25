require 'zip'

# Download a project's code from GitHub. Stores it in {SourceFile} models.
class Project::Download
  include Procto.call

  attr_reader :project, :logger, :http_client

  def initialize(project, logger: nil, http_client: HTTPClient)
    @project  = project
    @logger   = logger || Rails.logger
    @http_client = http_client
  end

  def call
    project.source_files.delete_all
    Tempfile.create([filename, ".zip"], :encoding => 'ascii-8bit') do |zip_file|
      http_client.get_content(project.download_zip_url) { |chunk|
        zip_file.write(chunk)
      }
      unzip_and_update_project(zip_file)
    end
  end

  private

  def filename
    "#{project.username}-#{project.name}"
  end

  # @param file [String]
  def unzip_and_update_project(filepath)
    zipfile = Project::ZipFile.new(filepath)
    project.has_todo = zipfile.has_rubocop_todos?
    save_as_source_files(zipfile.ruby_entries)
  end

  # Saves the files as {SourceFile} models
  #
  # @param [Array<Zip::Entry>] entries
  #
  # @return [undefined]
  def save_as_source_files(entries)
    entries.each do |entry|
      next if SourceFile::IgnoreCheck.call(entry.name)
      save_as_source_file(entry)
    end
  end

  def save_as_source_file(entry)
    sf = SourceFile.new(
      project:  project,
      path:     sanitize_file_path(entry),
      content:  read_content(entry),
    )
    return if sf.content.blank?
    sf.save!
    sf
  end

  # @param [Zip::Entry] entry
  def read_content(entry)
    input = entry.get_input_stream
    input.read if input.respond_to?(:read)
  rescue StandardError => e
    logger.warn "FAILED ON FILE: #{entry.name} #{e.inspect}"
    nil
  end

  # Pops of the name of the project directory ( == name of zip file )
  def sanitize_file_path(entry)
    parts = entry.name.split(File::SEPARATOR)
    parts.shift
    parts.join(File::SEPARATOR)
  end
end
