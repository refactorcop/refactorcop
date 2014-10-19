require 'zip'

# Download a project's code from GitHub
class Project::Download
  include Procto.call

  attr_reader :project, :logger

  def initialize(project)
    @project  = project
    @logger   = Rails.logger
  end

  def call
    project.source_files.destroy_all
    Tempfile.create([filename, ".zip"], :encoding => 'ascii-8bit') do |zip_file|
      HTTPClient.get_content(project.download_zip_url) { |chunk| zip_file.write(chunk) }


      tmp_dir = Dir.mktmpdir
      begin
        rescue_reopen_error { unzip_to_source_files(zip_file, tmp_dir) }

        run_rubocop(tmp_dir)

        # use the directory...
        #open("#{tmp_dir}/foo", "w") { ... }

      ensure
        # remove the directory.
        FileUtils.remove_entry tmp_dir
      end


    end
    @source_files
  end

  private

  def run_rubocop(dir)
    rubocop_path = Rails.root.join(".rubocop.yml")

    json_data = `cd #{dir}; bundle exec rubocop --config "#{rubocop_path}" -f json`

    json = MultiJson.load(json_data, symbolize_keys: true)

    #rewrite this to extract seperate files, and lookup the file in SourceFile Record
    json[:files].each do |files_json|
      sf = SourceFile.where(project: project, path: files_json[:path]).first

      files_json[:offenses].each do |offense_json|
        sf.rubocop_offenses.create({
          severity:   offense_json[:severity],
          message:    offense_json[:message],
          cop_name:   offense_json[:cop_name],
          location_column:  offense_json[:location][:column],
          location_line:    offense_json[:location][:line],
          location_length:  offense_json[:location][:length],
        })
      end
    end

  end

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
  def unzip_to_source_files(file, dir)

    Zip::File.open_buffer(file) do |zip_file|
      # Handle entries one by one
      @source_files = zip_file.glob('**/*.rb').compact.map do |entry|
        next if test_file?(entry.name)
        #logger.info { "Extracting #{entry.name.inspect}" }
        begin
          to_source_file(entry)
          to_tmp_dir(entry, dir)

        rescue StandardError => e
          puts "FAILED ON FILE: #{entry.name}"
          p e.inspect
          raise e
        end
      end
    end
  end

  def test_file?(filename)
    filename =~ /(spec|test)\//
  end

  def to_source_file(entry)
    sf = SourceFile.new(project: project, path: sanitize_file_path(entry))
    sf.content = entry.get_input_stream.read
    sf.save!
    #RubocopFileWorker.perform_async(sf.id)
    sf
  end

  def to_tmp_dir(entry, dir)
    relative_filename = sanitize_file_path(entry)
    f_path = File.join(dir, relative_filename)
    FileUtils.mkdir_p(File.dirname(f_path))
    entry.extract(f_path) unless File.exist?(f_path)
  end

  def sanitize_file_path(entry)
    parts = entry.name.split(File::SEPARATOR)
    parts.shift
    parts.join(File::SEPARATOR)
  end
end
