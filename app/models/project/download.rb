require 'zip'

# Download a project's code from GitHub
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
      unzip_to_source_files(zip_file)
    end
  end

  private

  def filename
    "#{project.username}-#{project.name}"
  end

  # @param file [String]
  def unzip_to_source_files(file)
    zipfile = Project::ZipFile.new(file, project: project)
    project.has_todo = zipfile.has_rubocop_todos?
    zipfile.source_files
  end
end
