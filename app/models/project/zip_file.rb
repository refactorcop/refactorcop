class Project::ZipFile
  attr_reader :file

  def initialize(file)
    unless file.kind_of?(IO)
      fail ArgumentError, "file must kind of IO object, but was #{file.class.name}"
    end
    @file = file
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
    # open_buffer reads zip archive contents from a String or open IO
    # stream, and outputs data to a buffer.
    Zip::File.open_buffer(file) do |zf|
      @has_rubocop_todos = zf.glob('**/.rubocop_todo.yml').present?
      @ruby_entries = zf.glob('**/*.rb').compact
    end
    @parsed = true
  end
end
