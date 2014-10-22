require 'zip'

# Download a project's code from GitHub
class Project::Download
  include Procto.call

  attr_reader :project, :logger, :http_client

  def initialize(project, tmp_dir, logger: nil, http_client: HTTPClient)
    @project  = project
    @logger   = logger || Rails.logger
    @tmp_dir  = tmp_dir
    @http_client = http_client
  end

  def call
    project.source_files.delete_all
    Tempfile.create([filename, ".zip"], :encoding => 'ascii-8bit') do |zip_file|
      http_client.get_content(project.download_zip_url) { |chunk| zip_file.write(chunk) }
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
    Zip::File.open_buffer(file) do |zip_file|
      zip_file.glob('**/*.rb').compact.map do |entry|
        next if ignore_file?(entry.name)
        source_file = to_source_file(entry)
        to_tmp_dir(entry, source_file.id) if source_file
      end
    end
  end

  def ignore_file?(filename)
    SourceFile::IgnoreCheck.call(filename)
  end

  def to_source_file(entry)
    sf = SourceFile.new(project: project, path: sanitize_file_path(entry))
    input_stream = entry.get_input_stream
    sf.content = input_stream.read if input_stream.respond_to?(:read)
    sf.save!
    sf
  rescue ActiveRecord::StatementInvalid => e
    logger.warn { "While inserting SourceFile content, ignoring exception: #{e.inspect}" }
    sf.update_attribute(:content, nil)
    sf
  rescue StandardError => e
    logger.warn "FAILED ON FILE: #{entry.name} #{e.inspect}"
    nil
  end

  def to_tmp_dir(entry, sf_id)
    f_path = File.join(@tmp_dir, "#{sf_id}.rb")
    entry.extract(f_path) unless File.exist?(f_path)
  rescue StandardError => e
    logger.warn "FAILED ON FILE: #{entry.name} #{e.inspect}"
  end

  def sanitize_file_path(entry)
    parts = entry.name.split(File::SEPARATOR)
    parts.shift
    parts.join(File::SEPARATOR)
  end
end
