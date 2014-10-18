require 'zip'

# Download a project's code from GitHub
class Project::Download
  include Procto.call

  attr_reader :project, :logger

  def initialize(project, logger: Rails.logger)
    @project  = project
    @logger   = logger
  end

  def call
    ActiveRecord::Base.transaction do
      project.source_files.destroy_all
      Tempfile.create([filename, ".zip"], :encoding => 'ascii-8bit') do |file|
        HTTPClient.get_content(project.download_zip_url) { |chunk| file.write(chunk) }
        rescue_reopen_error { unzip_to_source_files(file) }
      end
    end
    @source_files
  end

  private

  def filename
    "#{project.username}-#{project.name}"
  end

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
    Zip::File.open_buffer(file) do |zip_file|
      # Handle entries one by one
      @source_files = zip_file.glob('**/*.rb').compact.map do |entry|
        logger.info { "Extracting #{entry.name.inspect}" }
        to_source_file(entry)
      end
    end
  end

  def to_source_file(entry)
    SourceFile.new({
      project: project,
      content: entry.get_input_stream.read,
      path: sanitize_file_path(entry)
    })
  end

  def sanitize_file_path(entry)
    parts = entry.name.split(File::SEPARATOR)
    parts.shift
    parts.join(File::SEPARATOR)
  end
end
