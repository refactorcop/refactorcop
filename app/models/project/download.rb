require 'zip'

# Download a project's code from GitHub
class Project::Download
  include Procto.call

  attr_reader :project, :logger

  def initialize(project, tmp_dir, sidekiq_logger = nil)
    @project  = project
    @logger   = sidekiq_logger || Rails.logger
    @tmp_dir = tmp_dir
  end

  def call
    project.source_files.delete_all
    Tempfile.create([filename, ".zip"], :encoding => 'ascii-8bit') do |zip_file|
      HTTPClient.get_content(project.download_zip_url) { |chunk| zip_file.write(chunk) }
      rescue_reopen_error { unzip_to_source_files(zip_file) }
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
      @source_files = zip_file.glob('**/*.rb').compact.map do |entry|
        next if test_file?(entry.name)

        sf = to_source_file(entry)
        to_tmp_dir(entry, sf.id)
      end
    end
  end

  def test_file?(filename)
    filename =~ /(spec|test)\//
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
  rescue StandardError => e
    logger.warn "FAILED ON FILE: #{entry.name} #{e.inspect}"
  ensure
    sf
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
