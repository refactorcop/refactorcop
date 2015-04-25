class Project::ZipFile
  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
    @parsed = false
  end

  def has_rubocop_todos?
    parse_zipfile
    !!@has_rubocop_todos
  end

  # Returns all files with a `.rb` extension
  #
  # @return [Array<Zip::Entry>]
  def ruby_entries
    parse_zipfile
    @ruby_entries
  end

  private

  def parse_zipfile
    return if @parsed
    open_zip_file(filepath) do |zf|
      @has_rubocop_todos = zf.glob('**/.rubocop_todo.yml').present?
      @ruby_entries = zf.glob('**/*.rb').compact
    end
    @parsed = true
  end

  def open_zip_file(filepath, &block)
    File.open(filepath) do |f|
      # open_buffer reads zip archive contents from a String or open IO
      # stream, and outputs data to a buffer.
      Zip::File.open_buffer(f, &block)
    end
  end
end
