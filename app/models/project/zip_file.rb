class Project::ZipFile
  attr_reader :filepath, :project

  def initialize(filepath, project:, logger: Rails.logger)
    @filepath = filepath
    @project = project
    @parsed = false
    @logger = logger
  end

  def source_files
    parse_file
    @source_files
  end

  def has_rubocop_todos?
    parse_file
    !!@has_rubocop_todos
  end

  private

  attr_reader :logger

  def parse_file
    return if @parsed
    Zip::File.open_buffer(filepath) do |zf|
      @has_rubocop_todos = zf.glob('**/.rubocop_todo.yml').present?
      @source_files = zf.glob('**/*.rb').compact.map do |entry|
        next if ignore_file?(entry.name)
        to_source_file(entry)
      end
    end
    @parsed = true
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
    logger.warn {
      "While inserting SourceFile content, ignoring exception: #{e.inspect}"
    }
    sf.update_attribute(:content, nil)
    sf
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
