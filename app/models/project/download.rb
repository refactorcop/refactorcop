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
      rescue_reopen_error { unzip_to_source_files(zip_file) }
    end
  end

  private

  def filename
    "#{project.username}-#{project.name}"
  end

  # Catch and ignore weird `reopen` error message from rubyzip gem
  def rescue_reopen_error
    begin
      return yield
    rescue ArgumentError => e
      line = e.backtrace.first
      if line =~ /reopen/ && e.message =~ /wrong number of arguments \(0 for 1\.\.2\)/
        logger.warn { "While unzipping, ignoring exception: #{e.inspect}" }
      else
        raise e
      end
    end
  end

  # @param file [String]
  def unzip_to_source_files(file)
    zipfile = Project::ZipFile.new(file, project: project)
    project.has_todo = zipfile.has_rubocop_todos?
    zipfile.source_files
  end
end
